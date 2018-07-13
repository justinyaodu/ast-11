dir='/Users/ykko/Work/dwarf_gc/example/VCC2000/'

fl=file_lines(dir+'VCC2000.htm')

openr,lun,dir+'VCC2000.htm',/get_lun

line=''

lines=strarr(fl)

for i=0l,fl-1 do begin
	readf,lun,line
	lines[i]=line
endfor

close,lun & free_lun,lun

gal_div1=where(strmid(lines,0,9) eq "<br><b>''",ngal)
gal_div2=where(lines eq '</tbody></table>')

for i=0,ngal-1 do begin

	lines1=lines[gal_div1[i]:gal_div2[i]]
	galname=strmid(lines1[0],9,7)

	openw,lun,dir+'imUrlList.txt',/get_lun

	red_div1=where(strmid(lines1,11,/reverse_offset) eq 'color: red">',$
	nred)
	red_div2=where(lines1 eq '</tr>')
	
	for j=0,nred-1 do begin
		lines2=lines1[red_div1[j]:red_div2[j]]
		im_pos=where(strmid(lines2,0,12) eq '<td><a href=',nim)

		for k=0,nim-1 do begin
			elines2=strsplit(lines2[im_pos[k]],'"',/extract)
			printf,lun,elines2[1]
		endfor
	endfor

	close,lun & free_lun,lun
endfor

end
