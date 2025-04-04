{
  # This module configures the bank-tags-sync service and timer using systemd user services and timers.
  # https://rycee.gitlab.io/home-manager/options.xhtml#opt-systemd.user.services
  systemd.user.services = {
    # To run immediately, run: systemctl --user start bank-tags-sync.service
    "bank-tags-sync" = {
      Unit = {
        Description = "Sync bank tags.";
      };
      unitConfig = {
        Description = "Bank Tags Sync Service";
        After = [ "network-online.target" ];
        # The service will be skipped if this file does not exist.
        ConditionPathExists = ["%h/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM\ Alt-2611041402141.properties" "%h/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties"];
      };
      Service = {
        # ./bin/bank-tags-sync profile sync -r "/home/steven/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM Alt-2611041402141.properties" -s /home/steven/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties
        ExecStart = "bank-tags-sync profile sync -r \"%h/.var/app/com.adamcake.Bolt/data/bolt-launcher/.runelite/profiles2/GIM\ Alt-2611041402141.properties\" -s %h/go/src/github.com/Emyrk/bank-tags-sync/profiles/gim.properties";
        WorkingDirectory = "%h/go/src/github.com/Emyrk/bank-tags-sync";
        Restart = "no";
      };
    };
  };

  # https://rycee.gitlab.io/home-manager/options.xhtml#opt-systemd.user.timers
  systemd.user.timers = {
      # Define a timer that runs the service every 5 minutes.
    "bank-tags-sync" = {
      Unit = {
        Description = "Run bank tags sync every 5 minutes";
      };
      Timer = {
        OnCalendar = "*:0/5";
        Persistent = true;
      };
    };
  };

}