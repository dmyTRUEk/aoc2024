let
	inherit (builtins)
	;
	inherit (import <nixpkgs/lib>)
		range
	;
	inherit (import ./mylib.nix)
		_0
		_1
		bool_to_int
		elem_at_2d
		len
		split_lines
		string_to_list
		sum
		tensor_product
	;
	# lines_to_chars_arr2d = lines:
	# 	assert all (l: eq (len l) (len lines)) lines;
	# 	lines
	# 		|> map string_to_list
	# ;
	# optimization idea: map chars to ints, bc they probably use less memory: X->0 M->1 A->2 S->3
	is_xmas_or_rev = a: b: c: d: [a b c d] == ["X" "M" "A" "S"] || [a b c d] == ["S" "A" "M" "X"];
	count_hor = arr2d:
		tensor_product (range 0 (len arr2d - 4)) (range 0 (len arr2d - 1))
			|> map (xy:
				let x = _0 xy; y = _1 xy; in
				is_xmas_or_rev
					(elem_at_2d  x    y arr2d)
					(elem_at_2d (x+1) y arr2d)
					(elem_at_2d (x+2) y arr2d)
					(elem_at_2d (x+3) y arr2d)
					|> bool_to_int
			)
			|> sum
	;
	count_ver = arr2d:
		tensor_product (range 0 (len arr2d - 1)) (range 0 (len arr2d - 4))
			|> map (xy:
				let x = _0 xy; y = _1 xy; in
				is_xmas_or_rev
					(elem_at_2d x  y    arr2d)
					(elem_at_2d x (y+1) arr2d)
					(elem_at_2d x (y+2) arr2d)
					(elem_at_2d x (y+3) arr2d)
					|> bool_to_int
			)
			|> sum
	;
	count_diag = arr2d:
		tensor_product (range 0 (len arr2d - 4)) (range 0 (len arr2d - 4))
			|> map (xy:
				let x = _0 xy; y = _1 xy; in
				is_xmas_or_rev
					(elem_at_2d  x     y    arr2d)
					(elem_at_2d (x+1) (y+1) arr2d)
					(elem_at_2d (x+2) (y+2) arr2d)
					(elem_at_2d (x+3) (y+3) arr2d)
					|> bool_to_int
			)
			|> sum
	;
	count_antidiag = arr2d:
		tensor_product (range 0 (len arr2d - 4)) (range 0 (len arr2d - 4))
			|> map (xy:
				let x = _0 xy; y = _1 xy; in
				is_xmas_or_rev
					(elem_at_2d  x    (y+3) arr2d)
					(elem_at_2d (x+1) (y+2) arr2d)
					(elem_at_2d (x+2) (y+1) arr2d)
					(elem_at_2d (x+3)  y    arr2d)
					|> bool_to_int
			)
			|> sum
	;
	count_xmas = arr2d:
		(count_hor arr2d) +
		(count_ver arr2d) +
		(count_diag arr2d) +
		(count_antidiag arr2d)
	;
in
	input:
	input
		|> split_lines
		|> map string_to_list
		|> count_xmas
