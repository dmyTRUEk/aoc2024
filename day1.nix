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
		map_rec
		split_
		split_lines
		sum
		transpose
	;
in
	input:
	input
		|> split_lines
		|> map (split_ "   ")
		|> map_rec toInt
		|> transpose
		|> map (sort (a: b: a < b))
		|> transpose
		|> map (pair: (distance (_0 pair) (_1 pair)))
		|> sum
