;uses srtm so only adjust when srtm elevation is below certain threshold

Pro mod_lorey, in_lorey, index
	index1 = where(in_lorey[index] le 15, count1, complement=index2, ncomplement=count2)
	if (count1 gt 0) then begin
		in_lorey[index[index1]] = 3.21 * (in_lorey[index[index1]]^0.67)
	endif

	if (count2 gt 0) then begin
		in_lorey[index[index2]] = 3.7325 + 0.96 * in_lorey[index[index2]]
	endif

End

PRO hlorey_adjust, in_file, out_file, srtm_file, globcover_file
	;threshold
	thresh = 600

	min_adjust = 10 ;do not adjust below this hlorey

	in_info = file_info(in_file)

	nblocks = in_info.size/4/100
	remainder = in_info.size mod 400

	in_block = fltarr(nblocks)
	srtm_block = intarr(nblocks)
	globcover_block = bytarr(nblocks)

	openr, in_lun, in_file, /get_lun
	openr, srtm_lun, srtm_file, /get_lun
	openr, globcover_lun, globcover_file, /get_lun
	openw, out_lun, out_file, /get_lun

	for i=0ULL, 99ULL do begin

		readu, in_lun, in_block
		readu, srtm_lun, srtm_block
		readu, globcover_lun, globcover_block

		index = where((in_block ge min_adjust) and (srtm_block le thresh) and ((globcover_block eq 40) or (globcover_block eq 160)), count)
		if (count gt 0) then mod_lorey, in_block, index

		writeu, out_lun, in_block

	endfor

	if (remainder ne 0) then begin
		in_block = fltarr(remainder / 4)
		srtm_block = intarr(remainder / 4)
		globcover_block = bytarr(remainder / 4)

		readu, in_lun, in_block
		readu, srtm_lun, srtm_block
		readu, globcover_lun, globcover_block
		index = where((in_block ge min_adjust) and (srtm_block le thresh) and ((globcover_block eq 40) or (globcover_block eq 160)), count)
		;index = where((in_block gt 0) and (srtm_block le thresh), count)
		if (count gt 0) then mod_lorey, in_block, index

		writeu, out_lun, in_block

	endif

	free_lun, in_lun
	free_lun, srtm_lun
	free_lun, out_lun
	free_lun, globcover_lun

End
