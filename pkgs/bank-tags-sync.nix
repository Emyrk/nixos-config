{ pkgs ? import <nixpkgs> {}}:

let
  lib = pkgs.lib;
  buildGoModule = pkgs.buildGoModule;
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildGoModule rec {
  pname = "bank-tags-sync";       # Replace with your executable name
  version = "1.0.0";         # Update as needed

  # Fetch the source from GitHub. Replace owner, repo, rev, and sha256 with actual values.
  src = fetchFromGitHub {
    owner = "Emyrk"; # e.g. "golang"
    repo = "bank-tags-sync"; # e.g. "example"
    rev = "ed9ff603e9c0cc2f0c2703da127d6f073fd73703"; # Can be a tag, branch, or commit hash
    # sha256 = lib.fakeSha256; # Use nix-prefetch-github to compute

    # This will not work
    # nix-shell -p nix-prefetch-github.out -p nix-prefetch-git
    # nix-prefetch-github Emyrk bank-tags-sync --rev main

    # Run this to get the hash:
    #   nix-build pkgs/bank-tags-sync.nix
    sha256 = "sha256-vfAETU/r56tohoeN3Qnv+y4+erJvLz8y/My91sLGT7o=";
    # sha256-vfAETU/r56tohoeN3Qnv+y4+erJvLz8y/My91sLGT7o=
    postFetch = ''
      # Remove the ./bin directory to remove offending binaries
      rm -rf ./bin
    '';
  };

  

  # If your project doesn't vendor its dependencies, set this to null.
  # vendorHash = lib.fakeHash;
  vendorHash = "sha256-4jyjgrd0psQn7oOpZFOKLl7f0ytsdEReYUZCISdgx24=";
  

  # Specify which subpackage contains the main package if needed.
  # If your main package is at the repo root, this can be [ "." ].
  subPackages = [ "." ];
}