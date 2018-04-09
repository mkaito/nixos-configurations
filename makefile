targethost := root@adalind.mkaito.net
GIST_HASH := 2f8681cbc3069ffdb3d33bedcfbdf2f7

all: gist adalind

adalind:
	$(MAKE) -C adalind

gist: factorio_helpers.sh
	gist -p -u $(GIST_HASH) factorio_helpers.sh
	touch gist

.PHONY: adalind
