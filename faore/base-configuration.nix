{
  system.stateVersion = "18.03";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/sda3";
      preLVM = true;
    }
  ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = ["hv_vmbus" "hv_storvsc"];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  time.timeZone = "America/Seattle";

  networking.hostName = "blueberry-factorio";
  networking.interfaces.eth0.ipv4.addresses = [{address = "10.0.0.5"; prefixLength = 8; }];
  networking.defaultGateway = "10.0.0.1";
  networking.nameservers = ["10.0.0.2"];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAsDnGyK64NslbDppxhsYNeqPuDlo7fS2HB+McQaPykaVNA07YqY89KmzA56rkweBhkKyXHeYgNWMzhssDzc6l/3+UBby3XjAaIThVj+FnrTKJ7+mBq5+WjUuifMShqSl4p2FPKCw8F0Yt+GuGYBH6/OFqb7rLlzQEphcBZB+KzrkG11pxFYw/WZ5Kxk6ZLzDjC+94iERsWU7L6y1cyaaDY9t6dvmQ5VJdXP5XHeMbOPEKqN7L7x2EWv48N563Wr62BBXk49rjFRkdHD+dkhwmkD2MTvguYu7NiLllYzxSLKGCGQkim9m00T+pdikAypNvEG1ZHsg79dlGZ7iZ84a9pw== faore@admt.im"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOySJ7SAmh+3CBK4fagwkY9PsF6xF+9msMRoQN6JalpauQANALVsVDjC3heFH6Lc/tjLrhQ46oVO3xMFGVKxNe81gaWhvWPxytfH5V8FP52GWEo5HwwMd+VoEyJIYYbj10jwkuzutr9fF0qlp0nhR1IaTKnxJFxV8tUkpiC3a9Qf4yrNy7Ft6DMwyiZSh/mEx+S4LuMqayb93do7+ddlSAyb70NQrLv7H2IRA+qkAzPhZe80o3FqKRvXayH5GSSuYLFfEPFgy0guKAA7P2ICjddLJ+l8BAdTlF8ADY1Z97DvCAgG6CT4cnRzv+cSM+Uvd+ZTxBY6Z+U27kO2LB7UBhVLzrWHSRbv5KWaruFzhOD3E64y3+7XzUg0DpoeS2QVahYc3iF4FvpVfLLPX3F4aev/83Z05G6nEn8lDb1XPAV0KRwo0gB4cCknC6MurnIzxgAeElin9DL5KgVMgVr5jIgBhx01Z9VEVNs5UcMDrA2mXHenY0uAnNk+iWeKZdzxxet50gQuebJ5Q3jHCADS6WZZsBdjxTDiLNvBVo1OiaZ4/tubzVZdrmCkPZDyPUO04Gz7rqXdVFiqzCJgVbcv2gX1qe8UthlRmdblX+l2fY4gvAOGNchVG1cMmvuA5i27td0PqDh6I7kQPvqKQ3QkCI012hwW9ca5S3HGtQDgqSZQ== cardno:000607309598"
  ];
}
