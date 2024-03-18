.SILENT: switch

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

include ${ROOT_DIR}/me

load:
	test -f ${ROOT_DIR}/me || { echo "File ${ROOT_DIR}/me is required to know what machine config to use."; exit 7; }
	test $(ME_MACHINE) || { echo "Variable ME_MACHINE is required to know what machine config to use."; exit 7; }

whoami: load
	echo "Machine to be configured: ${ME_MACHINE}"
	

cleanup:
	sudo nix-collect-garbage -d

.PHONY: cleanup

switch: whoami
	if [ ${ME_MACHINE} = "terra" ]; then \
		sudo nixos-rebuild switch --flake .#desktop-amd64; \
	elif [ ${ME_MACHINE} = "sys76" ]; then \
		sudo nixos-rebuild switch --flake .#system76; \
	else \
		echo "Unknown 'uname -m' target" ; \
	fi

update:
	nix flake update

update-vscode-extensions:
	deno run --allow-env --allow-run --allow-net --allow-read --allow-write --unstable --no-check ~/.local/bin/nix-vscode-extensions.ts
