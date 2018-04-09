targethost := root@adalind.mkaito.net
GIST_HASH := 2f8681cbc3069ffdb3d33bedcfbdf2f7

adalind: adalind.nix $(wildcard modules/**/*.nix) $(wildcard pkgs/**/*.nix)
	NIXOS_CONFIG=$(PWD)/adalind.nix nixos-rebuild --target-host $(targethost) dry-activate

gist: factorio_helpers.sh
	gist -p -u $(GIST_HASH) factorio_helpers.sh
	touch gist
