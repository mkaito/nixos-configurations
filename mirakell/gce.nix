let
  credentials = {
    project = "personal-200614";
    serviceAccount = "886891010855-compute@developer.gserviceaccount.com";
    accessKey = "/home/chris/dev/nix/mkaito/keys/mkaito-personal.pem";
  };
in
{
  factorio =
  { resources, ... }:
  {
    deployment.targetEnv = "gce";
    deployment.gce = credentials // {
      instanceType = "n1-highcpu-4";
      region = "us-east4-c";
      tags = [ "factorio" ];
      network = resources.gceNetworks.factorio-net;
      ipAddress = resources.gceStaticIPs.factorio-ip;
      rootDiskSize = 20;
      rootDiskType = "ssd";
    };
  };

  resources.gceNetworks.factorio-net = credentials // {
    addressRange = "192.168.4.0/24";
    firewall.factorio = {
      targetTags = [ "factorio" ];
      allowed.udp = [ 34197 ];
    };
  };

  resources.gceImages.bootstrap = credentials // {
    name = "bootstrap";
    sourceUri = "gs://mkaito-nixos-images/nixos-image-18.03.131954.2569e482904-x86_64-linux.raw.tar.gz";
  };

  resources.gceStaticIPs.factorio-ip = credentials // {
    name = "factorio";
    region = "us-east4";
    ipAddress = "35.199.29.6";
  };
}
