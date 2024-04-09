{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # GPU + AMD stuff
    corectrl
    radeon-profile
    radeontop
    nvtopPackages.amd
    lm_sensors
  ];
}
