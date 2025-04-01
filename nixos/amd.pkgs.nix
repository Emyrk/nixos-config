{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # GPU + AMD stuff
    corectrl
    radeon-profile
    radeontop
    nvtopPackages.amd
    lm_sensors
    lact
  ];
  # AMD Fan speed control
  # https://wiki.nixos.org/wiki/AMD_GPU
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
}
