# TODO on new machines

## Tailscale

```
sudo tailscale up
```

## To build a local derivation

```
nix-build pkgs/<thing>>.nix
./result/bin/<bin>
```

## To see options

For nixos options: https://search.nixos.org/options For home-manager options:
https://rycee.gitlab.io/home-manager/options.html

## Mux skills

This repo syncs the full `home/mux-skills/` directory to `~/.mux/skills/` via Home Manager.

- Put repo-managed skills under `home/mux-skills/<skill-name>/SKILL.md`
- Apply with your normal switch workflow

You can also link a local skill directory directly:

```bash
mux-skill-add my-skill ~/path/to/my-skill
```

Requirements for linked skills:
- the source directory must exist
- it must contain `SKILL.md`
