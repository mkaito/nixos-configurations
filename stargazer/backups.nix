{
  services.borgbackup.jobs.backup = {
    encryption = {
      # Keep the encryption key in the repo itself
      mode = "repokey-blake2";

      # Password is used to decrypt the encryption key from the repo
      passCommand = "cat /root/secrets/borg-repo_password";
    };

    environment = {
      # Make sure we're using Borg >= 1.0
      BORG_REMOTE_PATH = "borg1";

      # SSH key is specific to the subaccount defined in the repo username
      BORG_RSH = "ssh -i /root/secrets/borg-ssh_private_key";
    };

    # Define remote Borg repository
    repo = "16785@ch-s010.rsync.net:stargazer";

    # Define schedule
    startAt = "hourly";

    prune.keep = {
      # hourly backups for the past week
      within = "7d";

      # daily backups for two weeks before that
      daily = 14;

      # weekly backups for a month before that
      weekly = 4;

      # monthly backups for 6 months before that
      monthly = 6;
    };
  };
}
