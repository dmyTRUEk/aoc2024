let
	inherit (builtins)
	;
	inherit (import <nixpkgs/lib>)
	;
	inherit (import ./mylib.nix)
	;
in
	input:
	input
