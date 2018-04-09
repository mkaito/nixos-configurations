targethost := root@adalind.mkaito.net

adalind: packet.nix hardware-configuration.nix
	NIXOS_CONFIG=$(PWD)/configuration.nix nixos-rebuild --target-host $(targethost) dry-activate

hardware-configuration.nix:
	rsync -vz $(targethost):/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
packet.nix: packet/host-id.nix packet/metadata.nix packet/standard.nix
	rsync -vz $(targethost):/etc/nixos/packet.nix ./packet.nix
packet/host-id.nix:
	mkdir -p packet
	rsync -vz $(targethost):/etc/nixos/packet/host-id.nix ./packet/host-id.nix
packet/metadata.nix:
	mkdir -p packet
	rsync -vz $(targethost):/etc/nixos/packet/metadata.nix ./packet/metadata.nix
packet/standard.nix:
	mkdir -p packet
	rsync -vz $(targethost):/etc/nixos/packet/standard.nix ./packet/standard.nix
