MAKEFILE := $(lastword $(MAKEFILE_LIST))
BASE_DIR := $(realpath $(dir $(MAKEFILE)))
TARGET_HOST := root@mirakell.mkaito.net

adalind: packet.nix hardware-configuration.nix
	NIXOS_CONFIG=$(BASE_DIR)/configuration.nix nixos-rebuild --target-host $(TARGET_HOST) switch

hardware-configuration.nix:
	rsync -vz $(TARGET_HOST):/etc/nixos/hardware-configuration.nix $(BASE_DIR)/hardware-configuration.nix
packet.nix: packet/host-id.nix packet/metadata.nix packet/standard.nix
	rsync -vz $(TARGET_HOST):/etc/nixos/packet.nix $(BASE_DIR)/packet.nix
packet/host-id.nix:
	mkdir -p packet
	rsync -vz $(TARGET_HOST):/etc/nixos/packet/host-id.nix $(BASE_DIR)/packet/host-id.nix
packet/metadata.nix:
	mkdir -p packet
	rsync -vz $(TARGET_HOST):/etc/nixos/packet/metadata.nix $(BASE_DIR)/packet/metadata.nix
packet/standard.nix:
	mkdir -p packet
	rsync -vz $(TARGET_HOST):/etc/nixos/packet/standard.nix $(BASE_DIR)/packet/standard.nix
