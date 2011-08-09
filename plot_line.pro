pro plot_line,line,over=over,_extra=_extra

  plot_command =(~keyword_set(over))?'plot,xrange=xrange,yrange=yrange':'oplot'

  x = findgen(100)
  y = line[0]*x + line[1]

  a = execute(plot_command+',x,y,_extra=_extra')


end
