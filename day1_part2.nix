let
	inherit (builtins)
		mul
	;
	inherit (import <nixpkgs/lib>)
		count
		toInt
		zipListsWith
	;
	inherit (import ./mylib.nix)
		_0
		_1
		eq
		map_recursive
		split_
		sum
		transpose
	;
in
	input:
	let
		lr = input
			|> split_ "\n"
			|> map (split_ "   ")
			|> map_recursive toInt
			|> transpose
		;
		l = _0 lr;
		r = _1 lr;
	in
		l
			|> map (v: count (eq v) r)
			|> zipListsWith mul l
			|> sum
