let
	inherit (builtins)
		all
		elem
		filter
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		toInt
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		_0
		_1
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
			# filter non-relevant rules: all same:
			# |> filter (rule: elem (_0 rule) page && elem (_1 rule) page)
			# |> filter (rule: all (rule_el: elem rule_el page) rule)
			|> filter (all (rule_el: elem rule_el page))
			|> map (rule: findFirstIndex (eq (_0 rule)) null page < findFirstIndex (eq (_1 rule)) null page)
			|> all id # "all is true"
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
			|> filter (is_in_correct_order rules)
			|> map get_middle_page
			|> sum
