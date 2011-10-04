function angleinrange,angle,width,question

range_angle = angle + ([-width,+width]/2.)

question = ((range_angle[0] lt 0) and (question gt range_angle[1]))?question-360:question

if ((question ge range_angle[0]) and (question le range_angle[1])) then return,1b else return,0b

end
