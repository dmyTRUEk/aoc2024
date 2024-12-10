let
	inherit (builtins)
		all
		filter
		isList
		length
		trace
	;
	inherit (import <nixpkgs/lib>)
		flatten
		sublist
		toInt
		unique
	;
	inherit (import ./mylib.nix)
		_0
		_1
		arr2d_is_in_0square
		elem_at_2d
		eq
		find_indices_in_arr2d
		map_rec
		ne
		string_to_arr2d
		sum
	;
	trailhead_rating_ = m: s: yx: prev_h:
		let
			y = _0 yx;
			x = _1 yx;
			h = elem_at_2d x y m;
		in
			if arr2d_is_in_0square s x y && h - prev_h == 1 then
				if h == 9 then
					{y=y; x=x;}
				else
					[ [y (x + 1)] [y (x - 1)] [(y + 1) x] [(y - 1) x] ]
					|> map (yx: trailhead_rating_ m s yx h)
					|> filter (ne null)
			else
				null
	;
	trailhead_rating = m: s: yx:
		trailhead_rating_ m s yx (-1)
			|> flatten
			|> length
	;
in
	input:
	let
		m = input |> string_to_arr2d |> map_rec toInt;
		s = length m;
		thyxs = m |> find_indices_in_arr2d (eq 0);
	in
		thyxs
			|> map (trailhead_rating m s)
			|> sum
