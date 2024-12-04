let
	inherit (builtins)
		add
		concatLists
		elemAt
		filter
		foldl'
		genList
		head
		isAttrs
		isList
		isString
		length
		match
		mul
		replaceStrings
		split
		stringLength
		substring
	;
	inherit (import <nixpkgs/lib>)
		drop
		fold
		ifilter0
		imap0
		last
		range
	;
in rec {
	todo = msg: throw "todo: " + msg;

	unreachable = msg: throw "unreachable reached: " + msg;

	split_ = sep_regex: str: filter (el: el != []) (split sep_regex str);

	split_lines = split_ "\n";

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

	# TODO: function composition

	remove_at = n: list: ifilter0 (i: v: i != n) list;

	id = x: x;

	# flatten_once = x:
	# 	if isList x
	# 	then concatMap id x
	# 	else throw "expected a list";

	flatten_once = concatLists;

	len = x:
		if isList x then length x
		else if isString x then stringLength x
		else throw "expected a list or a string";

	replace = from: to:
		if isString from && isString to then
			replaceStrings [from] [to]
		else if isList from && isString to then
			replaceStrings from (genList (x: to) (len from))
		else if isList from && isList to then
			replaceStrings from to
		else #if isString from && isList to then
			throw "expected string,string or list,string or list,list"
	;

	tensor_product_with_self = list:
		map
			(v:
				map
				(x: [v x])
				list
			)
			list
		|> flatten_once
	;

	dedup_consecutive = list:
		foldl'
			(acc: el:
				if acc == [] || last acc != el then acc ++ [el] else acc
			)
			[]
			list
	;

	drop_last = n: list:
		ifilter0
			(i: v: i < len list - n)
			list
	;

	tensor_product = list1: list2:
		map
			(v:
				map
				(x: [v x])
				list2
			)
			list1
		|> flatten_once
	;

	match_all_with_lenrange = minlen: maxlen: regex: string:
		tensor_product (range 0 (len string)) (range minlen maxlen)
			|> filter (il: _0 il + _1 il <= len string)
			|> map (il: substring (_0 il) (_1 il) string)
			|> map (match regex)
			|> filter (ne null)
			|> flatten_once
	;

	elem_at = i: list: elemAt list i;

	elem_at_2d = x: y: arr2d:
		arr2d
			|> elem_at y
			|> elem_at x
	;

	bool_to_int = b: if b then 1 else 0;

	juxt = v: fns:
		map
			(f: f v)
			fns
	;

	shift_l_once = list: (drop 1 list) ++ [(head list)];
	shift_r_once = list: [(last list)] ++ (drop_last 1 list);
	shift_l = n: list: if n == 0 then list else shift_l (n - 1) (shift_l_once list);
	shift_r = n: list: if n == 0 then list else shift_r (n - 1) (shift_r_once list);
}
