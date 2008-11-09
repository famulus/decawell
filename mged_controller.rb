require 'geometry'
require 'set'
require 'facets'
include Geometry

DB = "test3.g"
mged ="/usr/brlcad/rel-7.12.2/bin//mged -c  #{DB} "
scale_factor = 0.9 # global scaling factor
torus_ring_size = 0.65
torus = 0.125
torus_negative = 0.90 * torus
connector_thickness = torus * 0.5

`rm ./#{DB}`
`#{mged} 'units dm'` # set mged's units to decimeter 

Dodecahedron.icosahedron.each_with_index do |v,index|
	`#{mged} 'in torus#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus}'`
	# `#{mged} 'in torus_negative#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus_negative}'`
	# `#{mged} 'in cylinder_knockout#{index} rcc #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size* 1.2}.'`
	# `#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} - cylinder_knockout#{index}'`
	# `#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} '`
end
# `#{mged} 'r polywell_tori u #{(0...12).map{|index| "torus_shell#{index}"}.join(" u ")}'` 



Dodecahedron.edges.each_with_index do |edge,index| #insert the 30 connectors
	a = average(*edge.map{|e|e}) # the ideal location of the connector
	a = a * 0.95 # nudge the connector closer to the center

	b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half connector
	b = b*0.1 # scale the length of the connecter
	`#{mged} 'in connector1_#{index} rcc #{a[0]} #{a[1]} #{a[2]} #{b[0]} #{b[1]} #{b[2]} #{connector_thickness}'` 
	b = Vector[0,0,0]-b# scale the length of the connecter
	`#{mged} 'in connector2_#{index} rcc #{a[0]} #{a[1]} #{a[2]} #{b[0]} #{b[1]} #{b[2]} #{connector_thickness}'` 

end

`#{mged} 'r polywell u #{(0...12).map{|index| "torus#{index}"}.join(" u ")} u #{(0...29).map{|index| "connector1_#{index} u connector2_#{index}"}.join(" u ")}'` #union all the parts into a sings polywell object
`g-stl -o polywell.stl  test3.g polywell`


