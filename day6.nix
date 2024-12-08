let
	inherit (builtins)
		elemAt
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		mod
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		_0
		_1
		add_vec2d
		count_rec
		elem_
		elem_at_2d
		eq
		find_index_in_arr2d
		# join
		len
		replaced_arr2d
		string_to_arr2d
	;
	# map_to_string = m:
	# 	m
	# 		|> map (join "")
	# 		|> join "\n"
	# ;
	dirs = ["^" ">" "v" "<"];
	get_guard_yx = m:
		find_index_in_arr2d (elem_ dirs) m
			# |> swap # yx -> xy # disabled bc cant swap null
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
	step = m:
		let
			yx = get_guard_yx m;
			x = _1 yx;
			y = _0 yx;
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
	path_area = m:
		if (get_guard_yx m) == null then
			count_rec (eq "X") m
		else
			path_area (step m)
	;
in
	input:
	input
		|> string_to_arr2d
		|> path_area
