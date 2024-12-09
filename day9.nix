let
	inherit (builtins)
		div
		elemAt
		length
		trace
	;
	lib = import <nixpkgs/lib>;
	inherit (lib)
		flatten
		imap0
		init
		last
		mod
		replicate
		sublist
		toInt
	;
	inherit (lib.lists)
		findFirstIndex
	;
	inherit (import ./mylib.nix)
		eq
		index_of_last
		join
		string_to_list
		sum
	;
	decompress_disk = cd:
		cd
			|> imap0 (i: n:
				if mod i 2 == 0 then
					replicate n (div i 2)
				else
					replicate n null
			)
			|> flatten
	;
	last_non_null = ud:
		let last_ud = last ud; in
		if last_ud != null then
			last_ud
		else
			last_non_null (init ud)
	;
	index_of_first_null = ud:
		findFirstIndex (eq null) (-1) ud
	;
	ud_to_string = ud:
		ud
			|> map (n:
				if n != null then
					toString n
				else
					"."
			)
			|> join ""
	;
	remove_trailing_nulls = ud:
		if last ud != null then
			ud
		else
			remove_trailing_nulls (init ud)
	;
	defragment_disk_ = i: ud_:
		# trace i
		# trace (ud_to_string ud_)
		(
		let
			ud = remove_trailing_nulls ud_;
		in
		if i + 1 >= length ud then
			ud
		else if elemAt ud i == null then
			defragment_disk_
				(i + 1)
				((sublist 0 i ud) ++ [(last ud)] ++ (sublist (i+1) (length ud) (init ud)))
		else
			defragment_disk_ (index_of_first_null ud) ud
		)
	;
	defragment_disk = ud: defragment_disk_ (index_of_first_null ud) ud;
	calc_checksum = dd:
		dd
			|> imap0 (i: v: i*v)
			|> sum
	;
in
	input:
	input
		|> string_to_list
		|> map toInt
		|> decompress_disk
		|> defragment_disk
		|> calc_checksum
