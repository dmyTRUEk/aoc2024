let
	inherit (builtins)
		div
		elemAt
		length
		trace
	;
	inherit (import <nixpkgs/lib>)
		flatten
		imap0
		mod
		replicate
		sublist
		toInt
	;
	inherit (import ./mylib.nix)
		_0
		_1
		index_of_first
		index_of_last
		join
		string_to_list
		sum
	;
	d_to_string = d:
		d
			|> map (b:
				replicate (_0 b) (toString (if _1 b != null then _1 b else "."))
			)
			|> flatten
			|> join ""
	;
	d_to_string2 = d:
		# assert "all is [a b]";
		d
			|> map (b:
				"[" +
				toString (_0 b) +
				" " +
				toString (if _1 b == null then "." else _1 b) +
				"]"
			)
			|> join " "
	;
	d_to_rle = cd:
		cd |> imap0 (i: n:
			if mod i 2 == 0 then
				[n (div i 2)]
			else
				[n null]
		)
	;
	defragment_disk_ = id: d:
		trace ("id = " + toString id)
		(
		let
			r = index_of_last (b: _1 b == id) null d;
			R = elemAt d r;
			Rn = _0 R;
			Rd = _1 R;
			l = index_of_first (b: _1 b == null && _0 b >= Rn) null d;
			L = elemAt d l;
			Ln = _0 L;
			Ld = _1 L;
		in
		if id < 0 then
			d
		else if l == null || l > r then
			defragment_disk_ (id - 1) d
		else
			defragment_disk_ (id - 1) (
				(sublist 0 l d) ++
				[R] ++
				(if Ln - Rn > 0 then [[(Ln - Rn) null]] else []) ++
				(sublist (l+1) (r - (l+1)) d) ++
				[[Rn null]] ++
				(sublist (r+1) (length d - (r+1)) d)
			)
		)
	;
	defragment_disk = d: defragment_disk_ ((length d - 1) / 2) d;
	decompress_rle = d:
		d
			|> map (b: replicate (_0 b) (_1 b))
			|> flatten
	;
	calc_checksum = dd: dd |> imap0 (i: v: i * (if v == null then 0 else v)) |> sum;
in
	input:
	input
		|> string_to_list
		|> map toInt
		|> d_to_rle
		|> defragment_disk
		# |> d_to_string
		|> decompress_rle
		|> calc_checksum
