function long_hgihg,long,hg=hg,ihg=ihg,date=date
;+
; /hg keyword when the input is heliographic => output ihg
; /ihg keyword when the input is inertial heliographic => output hg
; This function converts between heliographic earth-sun ecliptic longitude and inertial
; heliographic longitud on a 2D system, without considering latitude variations.
; Look at ADS:1984SSRv...39..255B for more details between them.
; 
;-

if ~keyword_set(date) then date = systim()

jd_struct = anytim2jd(date)
jd = jd_struct.int + jd_struct.frac
helio, jd, 3, earth_rad,  earth_lon,  earth_lat
year = (strsplit(anytim(date,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
earth_lon = earth_lon - long_asc_node  ; ecliptic to ihg: ADS:1984SSRv...39..255B
if keyword_set(hg) then return,(long + earth_lon lt 0)?360 - abs(long + earth_lon) : long + earth_lon
if keyword_set(ihg) then return,long - earth_lon
if ~keyword_set(hg) and ~keyword_set(ihg) then begin
   message,'either hg or ihg(inertial) longitude needs to be input'
   return,-1
endif 
end
