let
	inherit (builtins)
		filter
	;
	inherit (import <nixpkgs/lib>)
		drop
		flatten
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		len
		split_
		split_lines
		sum
	;
	apply_add = nums:
		[(_0 nums + _1 nums) (drop 2 nums)] |> flatten
	;
	apply_mul = nums:
		[(_0 nums * _1 nums) (drop 2 nums)] |> flatten
	;
	is_solvable_ = res: nums:
		if len nums == 1 then
			res == _0 nums
		else
			(is_solvable_ res (apply_add nums)) ||
			(is_solvable_ res (apply_mul nums))
	;
	is_solvable = res_nums:
		is_solvable_ (_0 res_nums) (_1 res_nums)
	;
	line_to_res_nums = line:
		let
			res_nums = line |> split_ ": ";
			res = _0 res_nums |> toInt;
			nums = _1 res_nums |> split_ " " |> map toInt;
		in
			[res nums]
	;
in
	input:
	input
		|> split_lines
		|> map line_to_res_nums
		|> filter is_solvable
		|> map _0
		|> sum
