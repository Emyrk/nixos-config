{ pkgs ? import <nixpkgs> {}}:

let
  lib = pkgs.lib;
  buildGoModule = pkgs.buildGoModule;
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildGoModule rec {
  pname = "bank-tags-sync";       # Replace with your executable name
  version = "1.1.0";         # Update as needed

  # Fetch the source from GitHub. Replace owner, repo, rev, and sha256 with actual values.
  src = fetchFromGitHub {
    owner = "Emyrk"; # e.g. "golang"
    repo = "bank-tags-sync"; # e.g. "example"
    rev = "df7ff281a37285a23837e4c228ec7cc86f8e21f0"; # Can be a tag, branch, or commit hash
    # sha256 = lib.fakeSha256; # Use nix-prefetch-github to compute

    # This will not work
    # nix-shell -p nix-prefetch-github.out -p nix-prefetch-git
    # nix-prefetch-github Emyrk bank-tags-sync --rev main

    # Run this to get the hash:
    #   nix-build pkgs/bank-tags-sync.nix
    # If that does not work
    #   nix-hash  . --type sha256 --base64
    sha256 = "sha256-V7EdKBbBjiN2P8C1Mojh6DgEwxOVppgqyW4nPZxchAY=";
  };

  

  # If your project doesn't vendor its dependencies, set this to null.
  # vendorHash = lib.fakeHash;
  vendorHash = "sha256-tWzWX/oGRHjNRL/0gy8lNqw41d96ZAUBjN0zt1cvgMQ=";
  

  # Specify which subpackage contains the main package if needed.
  # If your main package is at the repo root, this can be [ "." ].
  subPackages = [ "." ];
}