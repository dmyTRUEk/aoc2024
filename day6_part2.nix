let
	inherit (builtins)
		elem
		elemAt
		filter
		hasAttr
		length
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		mod
		sublist
		unique
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		_0
		_01
		_1
		_2
		elem_at_2d
		eq
		find_index_in_arr2d
		join
		ne
		replaced_arr2d
		string_to_arr2d
	;

	is_blocked_at = x: y: m:
		if 0 <= x && x < length m && 0 <= y && y < length m then
			elem_at_2d x y m == "#"
		else
			false
	;

	dir_to_xy_delta_ = {
		"^" = [0 (-1)];
		">" = [1 0];
		"v" = [0 1];
		"<" = [(-1) 0];
	};
	dir_to_xy_delta = dir: dir_to_xy_delta_.${dir};
	dir_to_yx_delta_ = {
		"^" = [(-1) 0];
		">" = [0 1];
		"v" = [1 0];
		"<" = [0 (-1)];
	};
	dir_to_yx_delta = dir: dir_to_yx_delta_.${dir};

	# TODO(optim): try `dir_to_{y|x}_delta`

	# TODO(optim): benchmark which is faster -- same?
	# dirs = ["^" ">" "v" "<"];
	# get_next_dir = dir:
	# 	elemAt dirs (mod (findFirstIndex (eq dir) null dirs + 1) (length dirs))
	# ;
	dir_to_next_dir = {
		"^" = ">";
		">" = "v";
		"v" = "<";
		"<" = "^";
	};
	get_next_dir = dir: dir_to_next_dir.${dir};

	step = yxd: m: # alternative names: proceed, walk, advance
		let
			y = _0 yxd;
			x = _1 yxd;
			dir = _2 yxd;
			delta_yx = dir_to_yx_delta dir;
			next_y = y + _0 delta_yx;
			next_x = x + _1 delta_yx;
		in
			if is_blocked_at next_x next_y m then
				let next_dir = get_next_dir dir; in
				[y x next_dir]
			else
				[next_y next_x dir]
	;

	is_guard_on_map = yxd: m:
		let s = length m; y = _0 yxd; x = _1 yxd; in
		0 <= x && x < s &&
		0 <= y && y < s
	;

	is_looped_ = states: yxd: m:
		if !is_guard_on_map yxd m then
			false
		else if hasAttr (toString yxd) states then
			true
		else
			let yxd' = step yxd m; in
			is_looped_ (states // {${toString/*some voodoo optimization magic*/yxd}=0;}) yxd' m
	;
	is_looped = yxd: m: is_looped_ {} yxd m;

	get_trace_indices = yxd: m:
		if !is_guard_on_map yxd m then
			[]
		else
			let yxd' = step yxd m; in
			[yxd'] ++ get_trace_indices yxd' m
	;
in
	input:
	let
		m_initial = input |> string_to_arr2d;
		yxd = (find_index_in_arr2d (eq "^") m_initial) ++ ["^"];
		m_trace_indices = m_initial |> get_trace_indices yxd |> filter (ne yxd) |> map _01 |> unique;
	in
		m_trace_indices
			# |> sublist 0 1000 # FIXME
			|> map (yxd: replaced_arr2d (_1 yxd) (_0 yxd) "#" m_initial)
			|> filter (is_looped yxd)
			|> length
