.SILENT: switch

switch:
	if [ `uname -m` = "x86_64" ]; then \
		sudo nixos-rebuild switch --flake .#desktop-amd64; \
	else \
		echo "Unknown 'uname -m' target" ; \
	fi
update:
	nix flake update

update-vscode-extensions:
	deno run --allow-run --allow-net --allow-read --allow-write --unstable --no-check scripts/update-vscode-extensions.ts