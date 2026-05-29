{ pkgs, lib, config, ... }:

# Home-manager module that runs the my-agents-sync wrapper on every
# activation. The wrapper clones or updates ~/agent and creates symlinks
# into runtime-expected paths.
#
# The contract this implements is documented in
# https://github.com/Emyrk/my-agent/blob/main/docs/nixos-integration.md.

let
  my-agents = pkgs.callPackage ../pkgs/my-agents.nix { };
in
{
  home.packages = [ my-agents ];

  home.activation.myAgentsSync =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${my-agents}/bin/my-agents-sync
    '';
}
