function jd2ecs,jd
;+
; from a jd date produces a ECS format date: 
;    1998/05/23 10:11:34.432
;-

  daycnv,jd,yr,mn,d,hr
  min = (hr -fix(hr)) * 60.  
  seg = (min - fix(min)) * 60.

  if n_elements(jd) eq 1 then begin
     date = string(yr,mn,d,fix(hr),fix(min),seg, $
                   format = '(I4.4,2("/",I2.2)," ",2(I2.2,":"),F06.3)')
  endif else begin
     date = strarr(n_elements(jd))
     for i=0,n_elements(jd)-1 do date[i]=string(yr[i],mn[i],d[i],fix(hr[i]),fix(min[i]),seg[i], $
                   format = '(I4.4,2("/",I2.2)," ",2(I2.2,":"),F06.3)')
  endelse

  return,date
end

