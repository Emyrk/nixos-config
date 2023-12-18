{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # GPU + AMD stuff
    corectrl
    radeon-profile
    radeontop
    nvtop-amd
    lm_sensors
  ];
}
