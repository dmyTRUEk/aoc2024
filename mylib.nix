let
	inherit (builtins)
		add
		elemAt
		filter
		foldl'
		genList
		isAttrs
		isList
		length
		mul
		split
	;
	inherit (import <nixpkgs/lib>)
		fold
		imap0
	;
in rec {
	todo = msg: throw "todo: " + msg;

	unreachable = msg: throw "unreachable reached: " + msg;

	split_ = sep_regex: str: filter (el: el != []) (split sep_regex str);

	string_to_list = string: filter (el: el != "") (split_ "" string);

	repeat_string = string: n:
		if n == 0 then ""
		else (string + repeat_string string (n - 1));

	enumerate = list:
		foldl'
			(acc: el: acc ++ [[(length acc) el]])
			[]
			list;

	transpose = arr2d:
		foldl'
			(acc: el:
				imap0
					(i: v: v ++ [((elemAt el i))])
					acc
			)
			(genList (x: []) (length (elemAt arr2d 0)))
			arr2d
	;

	map_recursive = f: x:
		if isList x then
			map (map_recursive f) x
		else if isAttrs x then
			todo ""
		else
			f x
	;

	_0 = list: elemAt list 0;
	_1 = list: elemAt list 1;

	abs = x: if x > 0 then x else -x;

	distance = a: b: abs (a - b);

	# reduce = identity: f: list:
	# 	foldl'
	# 		f
	# 		identity
	# 		list
	# ;

	fold_ = identity: f: list:
		fold
			f
			identity
			list
	;

	sum = list:
		fold_
			0
			add
			list
	;

	prod = list:
		fold_
			1
			mul
			list
	;

	eq = a: b: a == b;
	ne = a: b: a != b;
	ll = a: b: a < b; # lessThan
	gg = a: b: a > b;
	le = a: b: a <= b;
	ge = a: b: a >= b;

	neg = x: -x;
}
