let
  credentials = {
    project = "uds-terraria";
    serviceAccount = "nixops@uds-terraria.iam.gserviceaccount.com";
    accessKey = "keys/underdogs.pem";
    region = "us-east4-b";
  };
in
  {
    defaults = {
      deployment.targetEnv = "gce";
      deployment.gce = credentials // {
        instanceType = "n1-standard-2";
        rootDiskType = "ssd";
        rootDiskSize = 20;
      };
    };

    factorio = { resources, config, ... }:
    {
      deployment.gce = {
        ipAddress = resources.gceStaticIPs.factorio-sip;
        machineName = "factorio";
        tags = [ "factorio" ];
      };
    };

    resources.gceImages.bootstrap = credentials // {
      sourceUri = "gs://admt-image-storage/nixos-image-18.09pre133640.ea145b68a01-x86_64-linux.raw.tar.gz";
    };

    resources.gceStaticIPs.factorio-sip =
    { lib, ... }:
    credentials // {
      region = lib.mkForce "us-east4";
      name = "factorio";
      ipAddress = "35.194.70.59";
      publicIPv4 = "35.194.70.59";
    };
  }
