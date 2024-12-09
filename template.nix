let
	inherit (builtins)
	;
	inherit (import <nixpkgs/lib>)
	;
	inherit (import ./mylib.nix)
		todo
		unreachable
	;
in
	input:
	input
