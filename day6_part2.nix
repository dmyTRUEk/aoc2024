let
	inherit (builtins)
		elem
		elemAt
		filter
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
		len
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

	get_guard_yx = m:
		find_index_in_arr2d (elem_ dirs) m
			# |> swap # yx -> xy # disabled bc cant swap null
	;

	get_guard_state_from_guard_yx = yx: m:
		yx ++ [(elem_at_2d (_1 yx) (_0 yx) m)]
	;

	get_guard_state = m:
		get_guard_state_from_guard_yx (get_guard_yx m) m
	;

	is_blocked_at = x: y: m:
		if 0 <= x && x < len m && 0 <= y && y < len m then
			elem_at_2d x y m == "#"
		else
			false
	;

	dir_to_xy_delta = dir:
		{
			"^" = [0 (-1)];
			">" = [1 0];
			"v" = [0 1];
			"<" = [(-1) 0];
		}.${dir}
	;

	next_dir = dir:
		elemAt dirs (mod (findFirstIndex (eq dir) null dirs + 1) (len dirs))
	;

	step = m: # alternative names: proceed, walk, advance
		let
			yx = get_guard_yx m;
			y = _0 yx;
			x = _1 yx;
			dir = elem_at_2d x y m;
			next_xy = add_vec2d [x y] (dir_to_xy_delta dir);
			next_x = _0 next_xy;
			next_y = _1 next_xy;
		in
			if is_blocked_at next_x next_y m then
				m
					|> replaced_arr2d x y (next_dir dir)
			else
				m
					|> replaced_arr2d x y "X"
					|> replaced_arr2d next_x next_y dir
	;

	do_steps = n: m:
		if n == 0 then
			m
		else
			do_steps (n - 1) (step m)
	;

	loop_step = m:
		if (get_guard_yx m) == null then
			m
		else
			loop_step (step m)
	;

	is_looped_ = states: m:
		let guard_yx = get_guard_yx m; in
		if guard_yx == null then
			false
		else if elem (get_guard_state_from_guard_yx guard_yx m) states then
			true
		else
			is_looped_ (states ++ [(get_guard_state_from_guard_yx guard_yx m)]) (step m)
	;
	is_looped = m: is_looped_ [] m;

	get_trace_indices_ = m:
		let guard_yx = get_guard_yx m; in
		if guard_yx == null then
			[]
		else
			[guard_yx] ++ get_trace_indices_ (step m)
	;
	# get_trace_indices_ = trace: m:
	# 	let guard_yx = get_guard_yx m; in
	# 	if guard_yx == null then
	# 		trace
	# 	else
	# 		get_trace_indices_ (trace ++ [guard_yx]) (step m)
	# ;
	get_trace_indices = m:
		indices_of_in_arr2d (eq "X") (loop_step m)
		# assert !(is_looped m);
		# get_trace_indices_ m
		# get_trace_indices_ [] m
	;
in
	input:
	let
		m_initial = input |> string_to_arr2d;
		guard_pos = get_guard_yx m_initial;
		m_trace_indices = m_initial |> get_trace_indices |> filter (ne guard_pos);
	in
		assert !(is_looped m_initial);
		m_trace_indices
			# |> sublist 0 10
			|> map (yx: replaced_arr2d (_1 yx) (_0 yx) "#" m_initial)
			# |> len
			# |> elem_at 30
			# |> m_to_string
			# |> is_looped
			# |> map m_to_string
			# |> map (ms: trace ("\n"+ms) 0)
			# |> map (do_steps 40)
			|> filter is_looped
			|> len

		# m_initial
		# 	|> replaced_arr2d 3 6 "#"
		# 	|> is_looped
			# |> loop_step
			# |> m_to_string
