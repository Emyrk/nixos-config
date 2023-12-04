{ pkgs, lib, ... }:

let
  protoc-gen-go-drpc = pkgs.callPackage ../pkgs/protoc-gen-go-drpc.nix { };
  coder = pkgs.callPackage ../pkgs/coder.nix { };
  dev-coder = pkgs.callPackage ../pkgs/dev-coder.nix { };


  vscodeExtensions = builtins.fromJSON (builtins.readFile ./programs/vscode/extensions.json);
  vscodeSettings = builtins.fromJSON (builtins.readFile ./programs/vscode/settings.json);
  vscodeKeybinds = builtins.fromJSON (builtins.readFile ./programs/vscode/keybindings.json);
  # nix-vscode-extensions = pkgs.callPackage ../pkgs/nix-vscode-extensions.nix { };
in
{
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  home = {
    username = "steven";
    homeDirectory = "/home/steven";
  };

  programs.home-manager.enable = true;
  services.syncthing = {
    tray = {
      enable = true;
    };
  };

  imports = [
    # Imports some OS system themeing.
    ./programs/xfce/xfce.nix
  ];

  home.packages = with pkgs; [
    # Productivity
    google-chrome
    slack
    htop
    dig
    jq
    yq
    nixpkgs-fmt
    jetbrains-toolbox
    discord
    kubecolor
    peek
    vlc
    sublime
    graphite-cli
    coder

    # Entertainment
    spotify

    # Programming
    vscode
    gnumake
    git
    gnome.dconf-editor
    go
    gotools
    gopls
    golangci-lint
    elixir
    docker-compose
    python3
    shellcheck
    # python2
    curl
    nodejs-18_x
    nodejs-18_x.pkgs.pnpm
    nodejs-18_x.pkgs.typescript
    nodejs-18_x.pkgs.typescript-language-server
    nodejs-18_x.pkgs.prettier
    yarn
    unzip
    protobuf # protoc
    protoc-gen-go
    protoc-gen-go-grpc
    sqlc
    dev-coder

    # Cloud
    fly
    google-cloud-sql-proxy

    # Required
    deno # For vscode extensions. Stolen, I mean borrowed from @kylecarbs
    # nix-vscode-extensions
    dconf2nix # TODO: https://github.com/gvolpe/dconf2nix look into this for customizing the theme with nix
    mockgen
    openssl

    # Custom
    protoc-gen-go-drpc
  ];

  programs.git = {
    enable = true;

    userName = "Steven Masley";
    userEmail = "stevenmasley@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      url."ssh://git@github.com/".insteadOf = [ "https://github.com/" ];

      # TODO: Meld for difftools
    };
  };

  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.ssh.matchBlocks
  programs.ssh.matchBlocks = {
    # Use the specified ssh key for github
    "github.com" = {
      hostname = "github.com";
      identityfile = " ~/.ssh/github";
    };
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./programs/vim/vimrc;
    plugins = with pkgs.vimPlugins; [
      vim-elixir
      # vim-mix-format
      rust-vim
      vim-go
    ];
  };

  programs.autojump.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
    };
    # histSize = 100000;
    # histFile = "./zsh/history";
    syntaxHighlighting = {
      enable = true;
    };
    enableAutosuggestions = true;

    zplug = {
      enable = true;
      plugins = [
        # { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        # { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
    initExtraBeforeCompInit = ''
      export PATH=$PATH:$HOME/.local/bin
    '';
    # initExtraBeforeCompInit = ''
    #     # p10k instant prompt
    #     P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
    #     [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
    #     '';
    initExtra = builtins.readFile ./programs/zsh/.zshrc;


    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./programs/zsh/p10k-config;
        file = "p10k.zsh";
      }
    ];
  };

  programs.vscode = {
    enable = true;
    # To add new extensions, add them to the vscode-extensions.json file and
    # then run `make update-vscode-extensions`.
    extensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace vscodeExtensions) ++ [
      # Terraform has a custom build script!
      pkgs.vscode-extensions.hashicorp.terraform
    ];
    userSettings = vscodeSettings;
    keybindings = vscodeKeybinds;
  };

  # Add in binaries
  home.file = {
    ".local/bin/" = {
      source = ./bin;
      recursive = true;
    };
  };

  # Add a .keep file in the Zwift directory so the folder always exists.
  # Syncthing uses this to sync Zwift workouts to the Zwift station.
  home.file = {
    "Desktop/Zwift/.keep".source = builtins.toFile "keep" "";
  };
}
