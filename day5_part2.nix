let
	inherit (builtins)
		all
		elem
		filter
		sort
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		findFirst
		toInt
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		_0
		_1
		elem_
		elem_at
		eq
		id
		len
		map_rec
		split_
		split_chunks
		split_lines
		sum
	;
	is_in_correct_order = rules: page:
		rules
			|> filter (all (rule_el: elem rule_el page))
			|> map (rule: findFirstIndex (eq (_0 rule)) null page < findFirstIndex (eq (_1 rule)) null page)
			|> all id # "all is true"
	;
	is_in_incorrect_order = rules: page: !(is_in_correct_order rules page);
	reorder_page = rules: page:
		sort
			(a: b:
				[a b] ==
				findFirst (elem_ [[a b] [b a]]) null rules
			)
			page
	;
	get_middle_page = page:
		elem_at ((len page - 1) / 2) page
	;
in
	input:
	let
		rules_pages = split_chunks input;
		rules = rules_pages |> _0 |> split_lines |> map (split_ "\\|") |> map_rec toInt;
		pages = rules_pages |> _1 |> split_lines |> map (split_   ",") |> map_rec toInt;
	in
		pages
			|> filter (is_in_incorrect_order rules)
			|> map (reorder_page rules)
			|> map get_middle_page
			|> sum
