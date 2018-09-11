targethost := root@adalind.mkaito.net
GIST_HASH := 2f8681cbc3069ffdb3d33bedcfbdf2f7

all: gist adalind

# Personal t1.small on Packet
adalind:
	$(MAKE) -C adalind

# NixOS machine at Faore's place
faore:
	$(MAKE) -C faore

gist: factorio_helpers.sh
	gist -p -u $(GIST_HASH) factorio_helpers.sh
	touch gist

.PHONY: adalind faore mirakell remeliez gist
