let
	inherit (builtins)
	;
	inherit (import <nixpkgs/lib>)
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		map_rec
		match_all_with_lenrange
		split_
		sum
	;
in
	input:
	input
		|> match_all_with_lenrange 8 12 ''mul\(([0-9]{1,3},[0-9]{1,3})\)''
		|> map (split_ ",")
		|> map_rec toInt
		|> map (xy: (_0 xy) * (_1 xy))
		|> sum
