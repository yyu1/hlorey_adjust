;uses srtm so only adjust when srtm stdev is below certain threshold

Pro mod_lorey, in_lorey, index
	index1 = where(in_lorey[index] le 150, count1, complement=index2, ncomplement=count2)
	if (count1 gt 0) then begin
		in_lorey[index[index1]] = 3.21 * (in_lorey[index[index1]]^0.67)
	endif

	if (count2 gt 0) then begin
		in_lorey[index[index2]] = 3.7325 + 0.96 * in_lorey[index[index2]]
	endif

End

PRO hlorey_adjust, in_file, out_file, srtm_stdev_file
	;threshold
	thresh = 30

	in_info = file_info(in_file)

	nblocks = in_info.size/4/100
	remainder = in_info.size mod 400

	in_block = fltarr(nblocks)
	srtm_block = intarr(nblocks)

	openr, in_lun, in_file, /get_lun
	openr, srtm_lun, srtm_stdev_file, /get_lun
	openw, out_lun, out_file, /get_lun

	for i=0ULL, 99ULL do begin

		readu, in_lun, in_block
		readu, srtm_lun, srtm_block

		index = where((in_block gt 0) and (srtm_block le thresh), count)
		if (count gt 0) then mod_lorey, in_block, index

		writeu, out_lun, in_block

	endfor

	if (remainder ne 0) then begin
		in_block = fltarr(remainder / 4)
		srtm_block = intarr(remainder / 4)

		readu, in_lun, in_block
		readu, srtm_lun, srtm_block
		index = where((in_block gt 0) and (srtm_block le thresh), count)
		if (count gt 0) then mod_lorey, in_block, index

		writeu, out_lun, in_block

	endif

	free_lun, in_lun
	free_lun, srtm_lun
	free_lun, out_lun
	

End