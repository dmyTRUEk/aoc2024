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
		toInt
	;
	inherit (import ./mylib.nix)
		# join
		string_to_list
		sum
	;
	# ud_to_string = ud:
	# 	ud
	# 		|> map (n: if n != null then toString n else ".")
	# 		|> join ""
	# ;
	decompress_disk = cd:
		cd
			|> imap0 (i: n:
				replicate n (if mod i 2 == 0 then div i 2 else null)
			)
			|> flatten
	;
	defragment_disk_ = i: j: ud:
		# trace (ud_to_string ud)
		trace ("i = " + toString i)
		trace ("j = " + toString j)
		(
		if i > j then
			[]
		else
			let ud_i = elemAt ud i; ud_j = elemAt ud j; in
			if ud_i != null then
				[ud_i] ++ defragment_disk_ (i + 1) j ud
			else if ud_j != null then
				[ud_j] ++ defragment_disk_ (i + 1) (j - 1) ud
			else
				defragment_disk_ i (j - 1) ud
		)
	;
	defragment_disk = ud: defragment_disk_ 0 (length ud - 1) ud;
	calc_checksum = dd: dd |> imap0 (i: v: i*v) |> sum;
in
	input:
	input
		|> string_to_list
		|> map toInt
		|> decompress_disk
		|> defragment_disk
		# |> ud_to_string
		|> calc_checksum
