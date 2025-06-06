# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  user = "steven";
in
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "tailscale0" ];
  };

  networking.extraHosts =
    ''
      192.168.86.57 homeassistant.internal # 8123
      192.168.86.201 proxmox.internal # 8006
      192.168.86.107 proxmox2.internal # 8006
      192.168.86.122 screeps.internal # 21025
    '';


  # Enable systemd user services.
  systemd.services.NetworkManager-wait-online = {
    # This is a hack https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };

  };

  # Useful for VS Code storing credentials.
  services.gnome.gnome-keyring.enable = true;

  # Set your time zone.
  # time.timeZone = "America/Chicago";
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # GPU Configuration
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # https://flatpak.org/setup/NixOS
  services.flatpak.enable = true;

  # programs.hyprland.enable = true;
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    excludePackages = with pkgs; [
      xterm
    ];
    # Enable the GNOME Desktop Environment.
    displayManager.gdm = {
      enable = true;
      # Wayland breaks discord share screen. Just use x11 for now.
      # :taco: to @Deansheather for the https://github.com/Vencord/Vesktop reccomendation
      # TODO: Try out Vencord, and maybe switch back to wayland.
      wayland = false;
    };
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.steven = {
    isNormalUser = true;
    description = "Steven Masley";
    extraGroups = [ "networkmanager" "wheel" "docker" "openrazer" "dialout" ];
    shell = pkgs.zsh;
  };

  imports = [
  ];

  # Add ~/.local/bin to path
  environment.localBinInPath = true;
  programs.zsh.enable = true;
  nix.settings.allowed-users = [ "steven" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow dynamic binaries: 
  # https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos
  programs.nix-ld = {
    enable = true;
    # List of libraries
    # https://github.com/nix-community/nix-index-database
    libraries = with pkgs; [
      # From https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/nix-ld.nix#L44C33-L59C7
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      # My custom additions
      # X11 for rendering stuff
      xorg.libX11
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXtst
      xorg.libXcomposite

      # From https://discourse.nixos.org/t/node2nix-issues/10762
      zlib
      glibc.out
      glibc.static
      libpng
      nasm
      cairo
      pango
      libuuid # canvas
      # cairo fixes
      freetype # undefined symbol: FT_Get_Transform
      libglibutil # undefined symbol: g_memdup2
      glib # undefined symbol: g_memdup2
      harfbuzz # undefined symbol: hb_ot_color_has_paint
      giflib
      glew
      mesa
      librsvg
    ];
  };
  # https://github.com/nix-community/nix-index?tab=readme-ov-file#usage-as-a-command-not-found-replacement
  # TODO: Look into this
  programs.command-not-found.enable = false;

  # Adjusts the scaling of the display.
  # environment.variables = {
  #   GDK_SCALE = "2";
  #   GDK_DPI_SCALE = "0.5";
  # };
  # Makes Chrome use dark mode by default!
  # environment.etc = {
  #   "xdg/gtk-3.0/settings.ini".text = ''
  #     [Settings]
  #     gtk-application-prefer-dark-theme=1
  #   '';
  # };

  services.mullvad-vpn = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      claude-code
      mullvad
      mullvad-vpn
      mullvad-browser


      polychromatic # Razer frontend
      openrazer-daemon

      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      hddtemp
      lshw
      hardinfo2
      wget
      firefox
      gdb
      dconf

      # Used to debug wayland vs x11
      xorg.xeyes

      # Hardware
      zenmonitor
      lm_sensors

      # This has to be done outside home manager, otherwise there is some file conflict.
      # "open-policy-agent" "terraform-and-hcl" "antlr-v4" "envfile" "gitlink" "github-copilot"
      (jetbrains.plugins.addPlugins jetbrains.goland [ "nixidea"])
      jetbrains.goland
      (jetbrains.plugins.addPlugins jetbrains.datagrip [ ]) # "github-copilot"
      jetbrains.datagrip
      jetbrains.idea-community

      # https://github.com/AvaloniaUI/Avalonia/issues/3020
      xorg.libX11 # for linking dynamic rendering libs
      xorg.libX11.dev # same as above
      # Node canvas stuff
      pango
      cairo
      # Fixed cairo issues, see above.
      freetype
      libglibutil
      glib
      harfbuzz
      giflib
      glew
      mesa
      librsvg
      libxisf

      # Required for pixijs/node to headless render
      xvfb-run
    ];

  # Thread about this: https://discourse.nixos.org/t/howto-disable-most-gnome-default-applications-and-what-they-are/13505/11
  environment.gnome.excludePackages = with pkgs.gnome; [
    # baobab      # disk usage analyzer
    # cheese      # photo booth
    # eog         # image viewer
    # gedit       # text editor
    # simple-scan # document scanner
    # evince      # document viewer
    # file-roller # archive manager
    # seahorse    # password manager

    # these should be self explanatory
    # gnome-calculator 
    # gnome-calendar 
    # gnome-characters 
    # gnome-clocks
    # gnome-contacts
    # gnome-logs 
    # gnome-maps
    # gnome-music
    # gnome-screenshot
    # gnome-system-monitor 
    # gnome-weather
    #  gnome-disk-utility
    # pkgs.gnome-connections
  ];

  programs.dconf.enable = true;
  services.tailscale.enable = true;

  # TODO: Thunar is stuck in light theme, so ignoring it for now.
  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images
  programs.thunar = {
    enable = false;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # The firewalls seems to be messing with Docker port forwarding?
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # From https://nixos.wiki/wiki/AMD_GPU for HIP libraries
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];


  hardware.openrazer.enable = true;

  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #   dataDir = "/home/${user}/.local/share/syncthing";
  #   configDir = "/home/${user}/.config/syncthing";
  #   user = "${user}";
  #   group = "users";
  #   guiAddress = "127.0.0.1:8384";
  #   overrideFolders = true;
  #   overrideDevices = true;

  #   settings.devices = {
  #     "Zwift Machine" = {
  #       id = "IJHYRHG-YYO2ERR-TQNJXA2-4LEQ6ZK-PYHXYJP-UFFAMJY-VFHCE7M-2YA6BA2";
  #       autoAcceptFolders = true;
  #       allowedNetwork = "192.168.86.0/16";
  #       addresses = [ "tcp://192.168.86.28:51820" ];
  #     };
  #   };
  #   settings.folders = {
  #     "Zwift" = {
  #       id = "kgmpk-o27t6";
  #       path = "/home/${user}/Desktop/Zwift";
  #       devices = [ "Zwift Machine" ];
  #     };
  #   };

  #   settings.options.globalAnnounceEnabled = false; # Only sync on LAN
  #   settings.gui.insecureSkipHostcheck = true;
  #   settings.gui.insecureAdminAccess = true;
  # };

  programs.steam = {
    enable = true;
    # If remote play is crashing, try disabling hardware decoding
    # settings -> remote play -> advanced client options -> disable hardware decoding
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.graphics.enable32Bit = true; # Enables support for 32bit libs that steam uses

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };
  virtualisation.docker = {
    enable = true;
    # daemon.settings = {

    # }
  };

  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 15d";
  };
}
