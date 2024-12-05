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
		bool_to_int
		map_rec
		remove_at
		split_
		split_lines
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
in
	input:
	input
		|> split_lines
		|> map (split_ " ")
		|> map_rec toInt
		|> map is_safe_with_problem_dampener
		|> map bool_to_int
		|> sum
