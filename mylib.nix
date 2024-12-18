let
	inherit (builtins)
		add
		concatLists
		elem
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
	lib = import <nixpkgs/lib>;
	inherit (lib)
		drop
		fold
		ifilter0
		imap0
		last
		range
		sublist
	;
	inherit (lib.lists)
		findFirstIndex
	;
in rec {
	# TODO(refactor): sort by alphabetic order.

	todo = msg: throw "todo: " + msg;

	unreachable = msg: throw "unreachable reached: " + msg;

	split_ = sep_regex: str: str |> split sep_regex |> filter (ne []);
	split_lines = split_ "\n";
	split_chunks = split_ "\n\n";

	string_to_list = string: string |> split_ "" |> filter (ne "");
	string_to_arr2d = string: string |> split_lines |> map string_to_list;

	repeat_string = string: n:
		if n == 0 then ""
		else (string + repeat_string string (n - 1))
	;

	enumerate = list:
		foldl'
			(acc: el: acc ++ [[(length acc) el]])
			[]
			list
	;

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

	map_rec = f: x:
		if isList x then
			map (map_rec f) x
		else if isAttrs x then
			todo ""
		else
			f x
	;

	_0 = list: elemAt list 0;
	_1 = list: elemAt list 1;
	_2 = list: elemAt list 2;

	_01 = sublist 0 2;
	# _02 = list: [(_0 list) (_2 list)];
	_12 = sublist 1 2;

	abs = x: if x > 0 then x else -x;
	div  = a: b: a / b;
	div_ = b: a: a / b;

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
	not = x: !x;

	# TODO(feat): function composition.

	remove_at = n: list: ifilter0 (i: v: i != n) list;

	id = x: x;

	# flatten_once = x:
	# 	if isList x
	# 	then concatMap id x
	# 	else throw "expected a list";

	flatten_once = concatLists;
	flatten_n = n: list:
		if n == 0 then
			list
		else
			flatten_n (n - 1) (flatten_once list)
	;

	# TODO(feat): flatten at some specific depth.

	len = x:
		if isList x then length x
		else if isString x then stringLength x
		else throw "expected a list or a string"
	;

	# TODO(feat): same but for list.
	replace = from: to:
		if isString from && isString to then
			replaceStrings [from] [to]
		else if isList from && isString to then
			replaceStrings from (genList (x: to) (length from))
		else if isList from && isList to then
			replaceStrings from to
		else #if isString from && isList to then
			throw "expected string,string or list,string or list,list"
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
			(i: v: i < length list - n)
			list
	;

	tensor_product = xs: ys:
		map
			(x:
				map
				(y: [x y])
				ys
			)
			xs
		|> flatten_once
	;
	tensor_product_with_self = list: tensor_product list list;

	match_all_with_lenrange = minlen: maxlen: regex: string:
		tensor_product (range 0 (len string)) (range minlen maxlen)
			|> filter (il: _0 il + _1 il <= stringLength string)
			|> map (il: substring (_0 il) (_1 il) string)
			|> map (match regex)
			|> filter (ne null)
			|> flatten_once
	;

	elem_ = list: el: elem el list;
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
	shift_r_once = list: [(last list)] ++ (drop_last 1 list); # TODO(refactor+optimization): `drop_last` -> `lib.init`
	shift_l = n: list: if n == 0 then list else shift_l (n - 1) (shift_l_once list);
	shift_r = n: list: if n == 0 then list else shift_r (n - 1) (shift_r_once list);

	# TODO(feat): function to swap arguments: swap_args (f a b) == (f b a). is it even possible/will be usable for |> ?

	# EXPERIMENTAL
	# TODO: test
	flatten_at = depth: list:
		if depth == 0 then
			flatten_once list
		else
			list |> map (l: flatten_at (depth - 1) l)
	;

	get_single = list:
		if length list == 1 then
			_0 list
		else
			throw "expected only one element in a list, but ${len list |> toString} was found"
	;

	get_single_or = default: list:
		if length list == 0 then
			default
		else if length list == 1 then
			_0 list
		else
			throw "expected at most one element in a list, but ${length list |> toString} was found"
	;

	count_rec = pred: list_or_el:
		if isList list_or_el then
			list_or_el
				|> map (count_rec pred)
				|> sum
		else
			pred list_or_el |> bool_to_int
	;

	swap = ab: [(_1 ab) (_0 ab)];

	join = sep: list:
		foldl'
			(acc: el:
				if acc == null then
					el
				else
					acc + sep + el
			)
			null
			list
			|> (s: if s == null then "" else s)
	;

	find_indices_in_arr2d = pred: arr2d:
		arr2d
			|> imap0 (i: list:
				list
					|> imap0 (j: v: if pred v then [i j] else null)
					|> filter (ne null)
			)
			|> flatten_once
	;

	find_index_in_arr2d = pred: arr2d:
		find_indices_in_arr2d pred arr2d
			|> get_single_or null
			# same, but slower:
			# |> imap0 (y: list:
			# 	list
			# 		|> imap0 (x: v: if pred v then [y x] else null)
			# 		|> filter (ne null)
			# 		|> get_single_or null
			# )
			# |> filter (ne null)
			# |> get_single_or null
	;

	# TODO(refactor): `*_vec2d` -> `vec2d_*`, maybe into separate file?
	add_vec2d = a: b:
		assert length a == 2;
		assert length b == 2;
		[(_0 a + _0 b) (_1 a + _1 b)]
	;
	sub_vec2d = a: b:
		assert length a == 2;
		assert length b == 2;
		[(_0 a - _0 b) (_1 a - _1 b)]
	;
	mul_vec2d = n: v:
		assert length v == 2;
		[(n * _0 v) (n * _1 v)]
	;
	mul_vec2d_ = v: n: mul_vec2d n v;
	neg_vec2d = a:
		assert length a == 2;
		[(-_0 a) (-_1 a)]
	;
	vec2d_is_xx = v: _0 v == _1 v;
	# checks if a < b
	vec2d_ll = a: b:
		if a == b then
			false
		else
			if _0 a == _0 b then
				_1 a < _1 b
			else
				_0 a < _0 b
	;

	replaced_arr2d = X: Y: new_value: arr2d:
		arr2d |> imap0 (y: line:
			if y != Y then line else
				line |> imap0 (x: v:
					if x != X then v else new_value
				)
		)
		# alternative implementation, but is bugs out `day6.nix`, same speed
		# (arr2d |> sublist 0 Y) ++
		# [(
		# 	let line = arr2d |> elem_at Y;
		# 	in
		# 		(line |> sublist 0 X) ++
		# 		[new_value] ++
		# 		(line |> sublist (X + 1) (length line))
		# )] ++
		# (arr2d |> sublist (Y + 1) (length arr2d) )
	;

	indices_of_in_arr2d = pred: arr2d:
		arr2d
			|> imap0 (y: line:
				line |> imap0 (x: v: [y x v])
			)
			|> flatten_once
			|> filter (yxv: pred (_2 yxv))
			|> map (yxv: [(_0 yxv) (_1 yxv)])
	;

	index_of_first_from = i: pred: default: list:
		let
			index_of_first_ = i: pred: default: list:
				if i >= length list then
					default
				else if pred (elemAt list i) then
					i
				else
					index_of_first_  (i + 1) pred default list
			;
		in
			index_of_first_ i pred default list
	;
	index_of_first = pred: default: list:
		index_of_first_from 0 pred default list
	;

	index_of_last_from = i: pred: default: list:
		let
			index_of_last_ = i: pred: default: list:
				if i < 0 then
					default
				else if pred (elemAt list i) then
					i
				else
					index_of_last_  (i - 1) pred default list
			;
		in
			index_of_last_ i pred default list
	;
	index_of_last = pred: default: list:
		index_of_last_from (length list - 1) pred default list
	;

	# TODO(feat): `index_of_last'` using method like in `findFirstIndex`.

	is_in_range = min: max: x: min <= x && x < max;
	arr2d_is_in_range = xmin: xmax: ymin: ymax: x: y:
		is_in_range xmin xmax x && is_in_range ymin ymax y
	;
	arr2d_is_in_0square = s: x: y: arr2d_is_in_range 0 s 0 s x y;

	# HINT: better just use `{...}` and then `flatten`.
	# unnest = list:
	# 	if all isList list then
	# 		list |> map unnest
	# 	else
	# 		list
	# ;
}
