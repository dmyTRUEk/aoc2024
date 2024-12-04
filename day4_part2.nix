let
	inherit (builtins)
		any
	;
	inherit (import <nixpkgs/lib>)
		range
	;
	inherit (import ./mylib.nix)
		_0
		_1
		bool_to_int
		elem_at_2d
		eq
		id
		juxt
		len
		shift_l
		shift_r
		split_lines
		string_to_list
		sum
		tensor_product
	;
	MMSS = ["M" "M" "S" "S"];
	is_x_mas = a: b: c: d: e:
		if a != "A" then
			false
		else
			any
				(eq MMSS)
				(juxt [b c d e] [
					id
					(shift_l 1)
					(shift_l 2)
					(shift_r 1)
				])
	;
	count_x_mas = arr2d:
		tensor_product (range 1 (len arr2d - 2)) (range 1 (len arr2d - 2))
			|> map (xy:
				let x = _0 xy; y = _1 xy; in
				is_x_mas
					(elem_at_2d  x       y      arr2d)
					(elem_at_2d (x + 1) (y + 1) arr2d)
					(elem_at_2d (x + 1) (y - 1) arr2d)
					(elem_at_2d (x - 1) (y - 1) arr2d)
					(elem_at_2d (x - 1) (y + 1) arr2d)
					|> bool_to_int
			)
			|> sum
	;
in
	input:
	input
		|> split_lines
		|> map string_to_list
		|> count_x_mas
