let
	inherit (builtins)
		all
		length
		tail
	;
	inherit (import <nixpkgs/lib>)
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		map_recursive
		split_
		sum
	;
	diff = list:
		if length list >= 2 then
			[((_0 list) - (_1 list))] ++ (diff (tail list))
		else
			[]
	;
	is_1_to_3 = x: 1 <= x && x <= 3;
	is_safe = report:
		let
			report_diff = diff report;
		in
			(all     is_1_to_3       report_diff) ||
			(all (x: is_1_to_3 (-x)) report_diff)
	;
	bool_to_int = bool: if bool then 1 else 0;
in
	input:
	input
		|> split_ "\n"
		|> map (split_ " ")
		|> map_recursive toInt
		|> map is_safe
		|> map bool_to_int
		|> sum
