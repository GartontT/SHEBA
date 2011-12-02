function jd2ecs,jd
;+
; from a jd date produces a ECS format date: 
;    1998/05/23 10:11:34.432
;-

  daycnv,jd,yr,mn,d,hr
  min = (hr -fix(hr)) * 60.  
  seg = (min - fix(min)) * 60.

  date = string(yr,mn,d,fix(hr),fix(min),seg, $
                format = '(I4.4,2("/",I2.2)," ",2(I2.2,":"),F06.3)')
  return,date
end

