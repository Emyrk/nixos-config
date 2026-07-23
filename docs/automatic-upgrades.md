# Automatic NixOS upgrades

This repository enables `system.autoUpgrade` for both the System76 laptop and
the Terra desktop.

## Normal behavior

The `nixos-upgrade.timer` unit starts an upgrade every day at 2:00 AM local
time. If the computer is off at that time, systemd starts the missed upgrade
after the computer is next turned on.

Each run:

1. Updates the locked `nixpkgs` flake input in `~/nixos-config/flake.lock`.
2. Builds the machine-specific NixOS configuration.
3. Switches to the new generation if the build succeeds.

Automatic reboots are disabled. A new kernel may be installed, but it will not
be used until the computer is rebooted manually.

Check the schedule and the most recent run with:

```bash
systemctl list-timers nixos-upgrade.timer --no-pager
systemctl status nixos-upgrade.timer --no-pager
systemctl status nixos-upgrade.service --no-pager
journalctl -u nixos-upgrade.service -n 200 --no-pager
```

A successful service is normally shown as `status=0/SUCCESS`. The service may
also appear as `inactive (dead)` after it finishes because it is a one-shot
job. The timer should remain `active (waiting)`.

## When to pause automatic upgrades

Pause automatic upgrades when any of these conditions apply:

- `nixos-upgrade.service` fails on multiple runs with the same error.
- A successful upgrade is followed by broken login, networking, graphics,
  audio, development tools, or another important workflow.
- The upgrade repeatedly fails to build after changing `flake.lock`.
- The Nix store or root filesystem is full and upgrades cannot finish.
- You need to hold the current package versions while investigating a
  regression.

A single failure caused by temporary loss of power, networking, GitHub, or a
binary cache usually does not require disabling the timer. Inspect the logs
and allow the next scheduled run to retry.

A long build or download is not by itself evidence of failure. Confirm the
service state and logs before interrupting it.

## Pause immediately

Prevent another run until the next reboot:

```bash
sudo systemctl mask --runtime --now nixos-upgrade.timer
```

This runtime mask is useful when you need time to investigate before editing
the NixOS configuration.

If an upgrade is already running, first inspect it:

```bash
systemctl status nixos-upgrade.service --no-pager
journalctl -fu nixos-upgrade.service
```

Prefer to let an active `nixos-rebuild switch` finish. If continuing would
cause immediate harm, stop it with:

```bash
sudo systemctl stop nixos-upgrade.service
```

Stopping a service mid-upgrade can leave the attempted generation unapplied,
but the previously booted generation remains available.

## Disable persistently

Edit `nixos/configuration.nix` and change:

```nix
system.autoUpgrade = {
  enable = true;
```

to:

```nix
system.autoUpgrade = {
  enable = false;
```

Then apply the configuration:

```bash
cd ~/nixos-config
make switch
```

Confirm that the timer is no longer scheduled:

```bash
systemctl status nixos-upgrade.timer --no-pager
systemctl list-timers nixos-upgrade.timer --no-pager
```

Disabling only the systemd timer is temporary. A later NixOS rebuild can
re-enable it while `system.autoUpgrade.enable` remains `true` in the
configuration.

## Investigate and recover

### 1. Read the failure

```bash
systemctl status nixos-upgrade.service --no-pager
journalctl -u nixos-upgrade.service -b --no-pager
journalctl -u nixos-upgrade.service --since "7 days ago" --no-pager
```

Look near the end for the first concrete build, evaluation, download, disk, or
activation error. Later lines often only report that the earlier command
failed.

### 2. Check repository changes

The updater is expected to update `flake.lock`. Check whether it left a change
and do not discard unrelated work:

```bash
cd ~/nixos-config
git status --short
git diff -- flake.lock
```

If the new lock file caused the problem, restore only that file to the last
committed version and rebuild:

```bash
git restore flake.lock
make switch
```

If the lock-file update is valid but the configuration no longer evaluates,
fix the reported Nix error and run `make switch` manually before re-enabling
automation.

### 3. Return to the previous generation when necessary

If the current generation introduced a runtime regression, switch back:

```bash
sudo nixos-rebuild switch --rollback
```

If the system cannot reach the desktop, reboot and select an older NixOS
generation from the boot menu. Automatic rebooting remains disabled, so an
upgrade will not reboot into a new generation on its own.

### 4. Check disk space

```bash
df -h / /nix/store
sudo nix-store --verify --check-contents
```

If disk space is the problem, review old generations before deleting them.
This repository already schedules Nix garbage collection for generations
older than 15 days.

## Test and re-enable

Before re-enabling the timer, verify that the configuration builds and applies
manually:

```bash
cd ~/nixos-config
make switch
```

Then change `system.autoUpgrade.enable` back to `true`, apply once more, and
remove any runtime mask:

```bash
cd ~/nixos-config
make switch
sudo systemctl unmask --runtime nixos-upgrade.timer
sudo systemctl start nixos-upgrade.timer
```

Verify the recovered state:

```bash
systemctl status nixos-upgrade.timer --no-pager
systemctl list-timers nixos-upgrade.timer --no-pager
```

Optionally test one upgrade immediately rather than waiting until 2:00 AM:

```bash
sudo systemctl start nixos-upgrade.service
systemctl status nixos-upgrade.service --no-pager
journalctl -u nixos-upgrade.service -n 200 --no-pager
```

Do not re-enable automatic upgrades until a manual `make switch` succeeds and
the issue that caused the pause is understood or resolved.
