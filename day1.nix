let
	inherit (builtins)
		sort
	;
	inherit (import <nixpkgs/lib>)
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		distance
		map_recursive
		split_
		sum
		transpose
	;
in
	input:
	input
		|> split_ "\n"
		|> map (split_ "   ")
		|> map_recursive toInt
		|> transpose
		|> map (sort (a: b: a < b))
		|> transpose
		|> map (pair: (distance (_0 pair) (_1 pair)))
		|> sum
