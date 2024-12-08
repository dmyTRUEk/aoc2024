let
	inherit (builtins)
		filter
		length
	;
	inherit (import <nixpkgs/lib>)
		flatten
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
		string_to_arr2d
		sub_vec2d
		vec2d_ll
		tensor_product_with_self
	;
	find_antinodes = ps:
		tensor_product_with_self ps
			|> filter (p1p2: _0 p1p2 != _1 p1p2)
			|> filter (p1p2: vec2d_ll (_0 p1p2) (_1 p1p2))
			|> map (p1p2: let p1 = _0 p1p2; p2 = _1 p1p2; in [
				(add_vec2d p1 (sub_vec2d p1 p2))
				(add_vec2d p2 (sub_vec2d p2 p1))
			])
	;
	is_in_map = s: p: 0 <= _1 p && _1 p < s && 0 <= _0 p && _0 p < s;
in
	input:
	let
		m = input |> string_to_arr2d;
		fs = m |> flatten |> unique |> remove ".";
		pss = fs |> map (f: find_indices_in_arr2d (eq f) m);
	in
		pss
			|> map find_antinodes
			|> flatten_n 2
			|> filter (is_in_map (length m))
			|> unique
			|> length
