{pkgs ? import <nixpkgs> {}, ...}:

let 
  # bank-tags-sync-pkg = pkgs.callPackage ../../../pkgs/bank-tags-sync.nix { };
in
{
  # This module configures the bank-tags-sync service and timer using systemd user services and timers.
  # https://rycee.gitlab.io/home-manager/options.xhtml#opt-systemd.user.services
  systemd.user.services = {
    "bank-tags-sync" = {
      Unit = {
        Description = "Sync bank tags.";
        After = [ "network-online.target" ];
        # The service will be skipped if this file does not exist.
        ConditionPathExists = [ "%h/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM\ Alt-2611041402141.properties" "%h/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties"];
      };
      Service = {
        # ExecCondition = "which bank-tags-sync";
        # ./bin/bank-tags-sync profile sync -r "/home/steven/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM Alt-2611041402141.properties" -s /home/steven/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties
        ExecStart = "%h/go/bin/bank-tags-sync profile sync -g -r \"%h/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM\ Alt-2611041402141.properties\" -s %h/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties";
        WorkingDirectory = "%h/go/src/github.com/Emyrk/bank-tags-sync";
        Restart = "no";
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };

  # https://rycee.gitlab.io/home-manager/options.xhtml#opt-systemd.user.timers
  systemd.user.timers = {
      # Define a timer that runs the service every 5 minutes.
    "bank-tags-sync" = {
      Unit = {
        Description = "Run bank tags sync every 5 minutes";
      };
      Timer = {
        OnCalendar = "*:0/5";
        Persistent = true;
      };
    };
  };

# Then
# systemctl --user daemon-reload
# systemctl --user enable --now bank-tags-sync.timer


# Status
# systemctl --user status bank-tags-sync.service
# systemctl --user status bank-tags-sync.timer

# To run immediately, run: systemctl --user start bank-tags-sync.service
}