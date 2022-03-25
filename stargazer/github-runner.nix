{ ... }:
{
  services.github-runner = {
    enable = true;
    name = "Stargazer";
    replace = true;

    tokenFile = "/root/secrets/github-runner-token";
    url = "https://github.com/OnHaven";
    extraLabels = [ "nix" "nixos" ];
  };
}
