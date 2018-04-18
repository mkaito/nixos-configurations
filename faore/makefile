MAKEFILE := $(lastword $(MAKEFILE_LIST))
BASE_DIR := $(realpath $(dir $(MAKEFILE)))
TARGET_HOST := root@home.admt

all: machine deps
deps: hardware-configuration.nix base-configuration.nix

machine: deps
	NIXOS_CONFIG=$(BASE_DIR)/configuration.nix nixos-rebuild --target-host $(TARGET_HOST) switch

## Get hardware-configuration.nix et al from target host
%-configuration.nix:
	rsync -vz $(TARGET_HOST):/etc/nixos/$@ $(BASE_DIR)/$@
