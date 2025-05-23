{ pkgs, lib, ... }:

let
  protoc-gen-go-drpc = pkgs.callPackage ../pkgs/protoc-gen-go-drpc.nix { };
  # curseforge = pkgs.callPackage ../pkgs/curseforge.nix { };
  coder = pkgs.callPackage ../pkgs/coder.nix { };
  dev-coder = pkgs.callPackage ../pkgs/dev-coder.nix { };
  # runemate = pkgs.callPackage ../pkgs/runemate.nix { };
  # bank-tags-sync = pkgs.callPackage ../pkgs/bank-tags-sync.nix { };


  vscodeExtensions = builtins.fromJSON (builtins.readFile ./programs/vscode/extensions.json);
  vscodeSettings = builtins.fromJSON (builtins.readFile ./programs/vscode/settings.json);
  vscodeKeybinds = builtins.fromJSON (builtins.readFile ./programs/vscode/keybindings.json);
  # nix-vscode-extensions = pkgs.callPackage ../pkgs/nix-vscode-extensions.nix { };

  nodejs = pkgs.nodejs_20;
  pnpm = pkgs.pnpm_9.override {
    inherit nodejs; # Ensure it points to the above nodejs version
  };
in
{
  home.stateVersion = "23.11";
  # nixpkgs.config.allowUnfree = true;
  home = {
    username = "steven";
    homeDirectory = "/home/steven";
  };

  programs.home-manager.enable = true;
  # services.syncthing = {
  #   tray = {
  #     enable = true;
  #   };
  # };

  imports = [
    # Imports some OS system themeing.
    ./programs/xfce/xfce.nix
    ./programs/bank-tags-sync/systemd.nix 
  ];

  # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  dconf.settings = {
    # This bell is annoying
    "org/gnome/desktop/wm/preferences".audible-bell = false;
    "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,close";

    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list --enabled` for a list
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "Vitals@CoreCoding.com"
        "clipboard-indicator@tudmotu.com"
      ];
    };

    # Extension settings
    # dconf dump / | dconf2nix
    "org/gnome/shell/extensions/vitals" = {
      fixed-widths = true;
      hide-icons = false;
      hot-sensors = [ "_memory_usage_" "_processor_usage_" "_temperature_k10temp_tccd1_" "_temperature_k10temp_tctl_" ];
      menu-centered = false;
      position-in-panel = 1;
      show-storage = true;
      show-voltage = false;
      unit = 1;
      use-higher-precision = true;
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      background-opacity = 0.8;
      click-action = "skip";
      custom-theme-shrink = false;
      dash-max-icon-size = 39;
      dock-position = "LEFT";
      height-fraction = 1.0;
      hide-tooltip = false;
      icon-size-fixed = false;
      isolate-monitors = true;
      isolate-workspaces = false;
      middle-click-action = "launch";
      multi-monitor = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-3";
      preview-size-scale = 0.0;
      scroll-action = "cycle-windows";
      shift-click-action = "minimize";
      shift-middle-click-action = "launch";
      show-apps-at-top = false;
    };
  };

  home.packages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals

    # Productivity
    nixpkgs-fmt
    code-cursor
    obsidian
    gimp # image editor
    ncdu # disk util
    google-chrome
    slack
    htop
    dig
    jq
    yq-go
    nixpkgs-fmt
    jetbrains-toolbox
    inetutils
    # https://github.com/NixOS/nixpkgs/issues/159267#issuecomment-1037372237
    # Work around #159267
    discord
    # (pkgs.writeShellApplication {
    #   name = "discord";
    #   text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    # })
    # (pkgs.makeDesktopItem {
    #   name = "discord";
    #   exec = "discord";
    #   desktopName = "Discord";
    # })
    kubecolor
    kooha # Screencap
    vlc
    sublime
    # coder
    zoom-us
    dconf-editor
    nix-direnv
    direnv
    traceroute
    kubernetes-helm

    # Entertainment
    spotify
    ferium # curseforge
    prismlauncher #mc


    # Programming
    code-cursor
    wireshark
    open-policy-agent
    spicedb-zed
    graphviz
    lsof
    kubectl
    gh
    supabase-cli
    gotestsum
    sqlite
    # go-migrate # currently broken with certs
    meld
    vscode
    gnumake
    graphite-cli
    go_1_24
    # git
    gotools
    gopls
    golangci-lint
    elixir
    docker-compose
    python3
    postgresql_jit
    shellcheck
    gofumpt
    chromium
    # python2
    arduino
    arduino-cli
    curl
    # Node
    nodejs
    nodejs.pkgs.typescript-language-server
    nodejs.pkgs.typescript
    nodejs.pkgs.prettier
    pnpm

    # nodejs-18_x
    # nodejs-18_x.pkgs.pnpm
    # nodejs-18_x.pkgs.typescript
    # nodejs-18_x.pkgs.typescript-language-server
    # nodejs-18_x.pkgs.prettier
    # yarn
    #
    unzip
    protobuf # protoc
    protoc-gen-go
    protoc-gen-go-grpc
    sqlc
    dev-coder
    terraform
    gcc
    shfmt
    pprof
    libsForQt5.kcachegrind # callgrind

    # Cloud
    flyctl
    google-cloud-sql-proxy

    # Required
    deno # For vscode extensions. Stolen, I mean borrowed from @kylecarbs
    # nix-vscode-extensions
    dconf2nix # TODO: https://github.com/gvolpe/dconf2nix look into this for customizing the theme with nix
    mockgen
    openssl

    # Custom
    protoc-gen-go-drpc
    # runemate
    runelite
    # bank-tags-sync
  ];

  programs.git = {
    enable = true;

    userName = "Steven Masley";
    userEmail = "stevenmasley@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      url."ssh://git@github.com/".insteadOf = [ "https://github.com/" ];
      difftool."meld".cmd = "meld $LOCAL $REMOTE";
      mergetool."meld".cmd = "meld $LOCAL $MERGED $REMOTE --output $MERGED";
      # removet those .orig files
      mergetool."keepBackup" = false;
      gpg.format = "ssh";
      commit.gpgsign = true;
      user.signingkey = "~/.ssh/github.pub";
      # This happened for some reason about dubious ownership.
      # Does not hurt to have.
      safe.directory = "*";

      # TODO: Meld for difftools
    };
    package = pkgs.gitFull;
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
      # vim-go
    ];
  };

  programs.autojump.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      lcoder = "~/go/bin/coder";
      lsqlc = "~/go/bin/sqlc";
      vi = "vim";
      grep = "grep --color";
      kubctl = "kubecolor";
      nix-shell = "nix-shell --run zsh";
    };
    # histSize = 100000;
    # histFile = "./zsh/history";
    syntaxHighlighting = {
      enable = true;
    };
    autosuggestion.enable = true;
    # enableAutosuggestions = true;

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        # { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
    initContent = ''
      export PATH=$PATH:$HOME/.local/bin

      ${builtins.readFile ./programs/zsh/.zshrc}
    '';
    # initExtraBeforeCompInit = ''
    #     # p10k instant prompt
    #     P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
    #     [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
    #     '';


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
    profiles.default = {
      # To add new extensions, add them to the vscode-extensions.json file and
      # then run `make update-vscode-extensions`.
      extensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace vscodeExtensions) ++ [
        # Terraform has a custom build script!
        pkgs.vscode-extensions.hashicorp.terraform
      ];
      userSettings = vscodeSettings;
      keybindings = vscodeKeybinds;
    };
    enable = true;
  };

  # Add in binaries
  home.file = {
    ".local/bin/" = {
      source = ./bin;
      recursive = true;
    };
  };


}
