let
	inherit (builtins)
		all
		any
		length
		tail
	;
	inherit (import <nixpkgs/lib>)
		imap0
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		map_recursive
		remove_at
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
	is_safe_with_problem_dampener = report:
		any is_safe (imap0 (i: v: remove_at i report) report)
	;
	bool_to_int = bool: if bool then 1 else 0;
in
	input:
	input
		|> split_ "\n"
		|> map (split_ " ")
		|> map_recursive toInt
		|> map is_safe_with_problem_dampener
		|> map bool_to_int
		|> sum
