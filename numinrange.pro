function numinrange,num,array
if ((n_elements(num) gt 1)) then begin
   print,'%% NumInRange needs a single value as to find if is in range'
   return,-1
endif
if (n_elements(array) ne 2)then begin
   print,'%% NumInRange needs a two elements array to define the range'
   return,-1
endif

;;TODO check that there is one value for num and two values for array

value_min = (num ge min(array))?1b:0b
value_max = (num le max(array))?1b:0b 

return, (value_min and value_max)
end

