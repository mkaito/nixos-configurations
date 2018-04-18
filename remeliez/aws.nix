let
  accessKeyId = "mkaito";
  region = "us-east-1";
  zone = "${region}a";
  domain = "mkaito.net";
in
  {
    network.description = "Factorio server for Underdogs";
    remeliez =
    { config, resources, lib, ... }:
    {
      deployment.targetEnv = "ec2";
      deployment.ec2 =
      {
        inherit accessKeyId region;
        associatePublicIpAddress = true;
        ebsInitialRootDiskSize = 30;
        keyPair = resources.ec2KeyPairs.default;
        securityGroupIds = [ resources.ec2SecurityGroups.factorio-sg.name ];
        securityGroups = [];
        subnetId = lib.mkForce resources.vpcSubnets.factorio-subnet;
        instanceType = "c5.xlarge";
      };

      deployment.route53 =
      {
        inherit accessKeyId;
        usePublicDNSName = true;
        hostName =  "${config.networking.hostName}.${domain}";
      };
    };

    resources = rec {
      vpc.factorio-vpc = {
        inherit region accessKeyId;
        instanceTenancy = "default";
        enableDnsSupport = true;
        enableDnsHostnames = true;
        cidrBlock = "10.0.0.0/16";
      };

      vpcSubnets.factorio-subnet =
      { resources, lib, ... }:
      {
        inherit region accessKeyId zone;
        vpcId = resources.vpc.factorio-vpc;
        cidrBlock = "10.0.0.0/19";
        mapPublicIpOnLaunch = true;
      };

      ec2SecurityGroups.factorio-sg =
      { resources, lib, ... }:
      {
        inherit region accessKeyId;
        vpcId = resources.vpc.factorio-vpc;
        rules = [
          { fromPort =    22; toPort =    22; sourceIp = "0.0.0.0/0"; }
          # { fromPort =    80; toPort =    80; sourceIp = "0.0.0.0/0"; }
          # { fromPort =   443; toPort =   443; sourceIp = "0.0.0.0/0"; }
          ## prometheus node exporter
          # { fromPort =  9100; toPort =  9100; sourceIp = vpc.factorio-vpc.cidrBlock; }
          ## mosh
          { fromPort = 60000; toPort = 60010; protocol = "udp"; sourceIp = "0.0.0.0/0"; }
          ## factorio
          { fromPort = 34197; toPort = 34197; protocol = "udp"; sourceIp = "0.0.0.0/0"; }
        ];
      };

      vpcRouteTables.factorio-route-table =
      { resources, ... }:
      {
        inherit region accessKeyId;
        vpcId = resources.vpc.factorio-vpc;
      };

      vpcRouteTableAssociations.factorio-assoc =
      { resources, ... }:
      {
        inherit region accessKeyId;
        subnetId = resources.vpcSubnets.factorio-subnet;
        routeTableId = resources.vpcRouteTables.factorio-route-table;
      };

      vpcInternetGateways.factorio-igw =
      { resources, ... }:
      {
        inherit region accessKeyId;
        vpcId = resources.vpc.factorio-vpc;
      };

      vpcRoutes.factorio-route =
      { resources, ... }:
      {
        inherit region accessKeyId;
        routeTableId = resources.vpcRouteTables.factorio-route-table;
        destinationCidrBlock = "0.0.0.0/0";
        gatewayId = resources.vpcInternetGateways.factorio-igw;
      };

      ec2KeyPairs.default = {
        inherit accessKeyId region;
      };
    };
  }
