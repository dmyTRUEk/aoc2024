let
	inherit (builtins)
		filter
		length
	;
	inherit (import <nixpkgs/lib>)
		flatten
		range
		remove
		unique
	;
	inherit (import ./mylib.nix)
		_0
		_1
		add_vec2d
		eq
		find_indices_in_arr2d
		flatten_n
		mul_vec2d
		string_to_arr2d
		sub_vec2d
		tensor_product_with_self
		vec2d_ll
	;
	find_antinodes = s: ps:
		tensor_product_with_self ps
			|> filter (p1p2: _0 p1p2 != _1 p1p2)
			|> filter (p1p2: vec2d_ll (_0 p1p2) (_1 p1p2))
			|> map (p1p2: let p1 = _0 p1p2; p2 = _1 p1p2; d = sub_vec2d p1 p2; in
				range (-s) s
					|> map (n: add_vec2d p1 (mul_vec2d n d))
					# |> filter (is_in_map s) # optimization, but no need
			)
	;
	is_in_map = s: p: 0 <= _1 p && _1 p < s && 0 <= _0 p && _0 p < s;
in
	input:
	let
		s = length m;
		m = input |> string_to_arr2d;
		fs = m |> flatten |> unique |> remove ".";
		pss = fs |> map (f: find_indices_in_arr2d (eq f) m);
	in
		pss
			|> map (find_antinodes s)
			|> flatten_n 2
			|> filter (is_in_map s)
			|> unique
			|> length
