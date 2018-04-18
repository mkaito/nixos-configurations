{
  defaults = { lib, ... }:
  {
    users.mutableUsers = lib.mkforce true;
  };

  factorio = (import ./configuration.nix);
}
