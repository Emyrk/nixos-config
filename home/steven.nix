{ pkgs, ... }:

let
    vscodeExtensions = builtins.fromJSON (builtins.readFile ./vscode/extensions.json);
    vscodeSettings = builtins.fromJSON (builtins.readFile ./vscode/settings.json);
in
{
    home.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;
    home = {
        username = "steven";
        homeDirectory = "/home/steven";
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
        spotify
        # chrome
        vscode
        gnumake
        git
        nvtop-amd
        google-chrome
        gnome.dconf-editor
    ];

    programs.git = {
        enable = true;

        userName = "Steven Masley";
        userEmail = "stevenmasley@gmail.com";

        extraConfig = {
            push.autoSetupRemote = true;
            init.defaultBranch = "main";
            core.editor = "code --wait";
        };
    };

    # programs.vscode = {
    #     enable = true;
    #     # To add new extensions, add them to the vscode-extensions.json file and
    #     # then run `make update-vscode-extensions`.
    #     extensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace vscodeExtensions) ++ [
    #         # Terraform has a custom build script!
    #         pkgs.vscode-extensions.hashicorp.terraform
    #     ];
    # };
}