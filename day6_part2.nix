let
	inherit (builtins)
		elem
		elemAt
		filter
		length
		trace
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		imap0
		mod
		range
		sublist
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		_0
		_1
		_2
		add_vec2d
		count_rec
		elem_
		elem_at
		elem_at_2d
		eq
		find_index_in_arr2d
		flatten_once
		indices_of_in_arr2d
		join
		# len
		ne
		replaced_arr2d
		string_to_arr2d
	;

	m_to_string = m:
		m
			|> map (join "")
			|> join "\n"
	;

	dirs = ["^" ">" "v" "<"];

	# get_guard_yx = m:
	# 	find_index_in_arr2d (elem_ dirs) m
	# 		# |> swap # yx -> xy # disabled bc cant swap null
	# ;

	get_guard_state_from_guard_yx = yx: m:
		yx ++ [(elem_at_2d (_1 yx) (_0 yx) m)]
	;

	# get_guard_state = m:
	# 	get_guard_state_from_guard_yx (get_guard_yx m) m
	# ;

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

	# TODO(optim): benchmark which is faster -- same?
	# next_dir = dir:
	# 	elemAt dirs (mod (findFirstIndex (eq dir) null dirs + 1) (length dirs))
	# ;
	dir_to_next_dir = {
		"^" = ">";
		">" = "v";
		"v" = "<";
		"<" = "^";
	};
	next_dir = dir: dir_to_next_dir.${dir};

	step = yx: m: # alternative names: proceed, walk, advance
		let
			y = _0 yx;
			x = _1 yx;
			dir = elem_at_2d x y m; # TODO(optim)
			next_yx = add_vec2d yx (dir_to_yx_delta dir);
			next_y = _0 next_yx;
			next_x = _1 next_yx;
		in
			# TODO(optim): rewrite without `replaced_arr2d`, use `guard_state` & `m_initial`
			if is_blocked_at next_x next_y m then
				[yx (m |> replaced_arr2d x y (next_dir dir))]
			else
				[next_yx (m |> replaced_arr2d x y "X" |> replaced_arr2d next_x next_y dir)]
	;

	do_steps = n: guard_yx: m:
		if n == 0 then
			[guard_yx m]
		else
			let guard_yx_m' = step guard_yx m; guard_yx' = _0 guard_yx_m'; m' = _1 guard_yx_m'; in
			do_steps (n - 1) guard_yx' m'
	;

	is_guard_on_map = guard_yx: m:
		let s = length m; in
		0 <= _1 guard_yx && _1 guard_yx < s &&
		0 <= _0 guard_yx && _0 guard_yx < s
	;

	loop_step = guard_yx: m:
		if !is_guard_on_map guard_yx m then
			m
		else
			let guard_yx_m' = step guard_yx m; guard_yx' = _0 guard_yx_m'; m' = _1 guard_yx_m'; in
			loop_step guard_yx' m'
	;

	is_looped_ = states: guard_yx: m:
		let guard_state = get_guard_state_from_guard_yx guard_yx m; in
		if !is_guard_on_map guard_yx m then
			false
		else if elem guard_state states then
			true
		else
			let guard_yx_m' = step guard_yx m; guard_yx' = _0 guard_yx_m'; m' = _1 guard_yx_m'; in
			is_looped_ (states ++ [guard_state]) guard_yx' m'
	;
	is_looped = guard_yx: m: is_looped_ [] guard_yx m;

	get_trace_indices_ = guard_yx: m:
		if !is_guard_on_map guard_yx m then
			[]
		else
			let guard_yx_m' = step guard_yx m; guard_yx' = _0 guard_yx_m'; m' = _1 guard_yx_m'; in
			[guard_yx'] ++ get_trace_indices_ guard_yx' m'
	;
	# get_trace_indices_ = trace: m:
	# 	let guard_yx = get_guard_yx m; in
	# 	if guard_yx == null then
	# 		trace
	# 	else
	# 		get_trace_indices_ (trace ++ [guard_yx]) (step m)
	# ;
	get_trace_indices = guard_yx: m:
		indices_of_in_arr2d (eq "X") (loop_step guard_yx m)
		# assert !(is_looped m);
		# get_trace_indices_ m
		# get_trace_indices_ [] m
	;
in
	input:
	let
		m_initial = input |> string_to_arr2d;
		guard_yx = find_index_in_arr2d (eq "^") m_initial;
		m_trace_indices = m_initial |> get_trace_indices guard_yx |> filter (ne guard_yx);
	in
		# m_initial
		# 	|> do_steps 55 guard_yx
			# |> _1
			# |> m_to_string

		# assert !(is_looped guard_yx m_initial);
		m_trace_indices
			|> sublist 0 10 # FIXME
			|> map (yx: replaced_arr2d (_1 yx) (_0 yx) "#" m_initial)
			# |> length
			# |> elem_at 30
			# |> loop_step guard_yx
			# |> is_looped guard_yx
			# |> m_to_string
			# |> map m_to_string
			# |> map (ms: trace ("\n"+ms) 0)
			# |> map (do_steps 40)
			|> filter (is_looped guard_yx)
			|> length
