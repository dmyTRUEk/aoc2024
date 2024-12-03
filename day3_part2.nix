let
	inherit (builtins)
		filter
		foldl'
		match
	;
	inherit (import <nixpkgs/lib>)
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		map_recursive
		match_all_with_lenrange
		ne
		split_
		sum
		unreachable
	;
	filter_donts = list:
		(foldl'
			(acc: el:
				acc // (
					if el == "do" then
						{ do = true; }
					else if el == "don't" then
						{ do = false; }
					else if acc.do then
						if match "[0-9]{1,3},[0-9]{1,3}" el != null then
							{ list = acc.list ++ [el]; }
						else
							unreachable ""
					else
						{}
				)
			)
			{ do = true; list = []; }
			list
		).list
	;
in
	input:
	input
		|> match_all_with_lenrange 4 12 ''mul\(([0-9]{1,3},[0-9]{1,3})\)|(do)\(\)|(don't)\(\)''
		|> filter (ne null) # where these nulls come from??
		|> filter_donts
		|> map (split_ ",")
		|> map_recursive toInt
		|> map (xy: (_0 xy) * (_1 xy))
		|> sum
