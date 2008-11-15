require 'geometry'
include Geometry

require 'set'
require 'facets'

DB = "test3.g"
mged ="/usr/brlcad/rel-7.12.2/bin//mged -c  #{DB} "
scale_factor = 0.75 # global scaling factor
torus_ring_size = 0.55 *scale_factor
torus = 0.22 *scale_factor
torus_negative = 0.83 * torus
connector_radius = torus * 0.7
connector_negative_radius = connector_radius * 0.20
joint_nudge = 0.863 # this is a percentage scaling of the vector defining the ideal joint location

derived_dimentions = {
:outside_radius => (Dodecahedron.vertices[0].r) ,
:torus_midplane_radius => (Dodecahedron.icosahedron[0].r),
:torus_radius => torus_ring_size,
:torus_tube_radius => torus,
:torus_tube_wall_thickness => torus-torus_negative,
:torus_tube_hollow_radius => torus_negative,
:joint_radius => connector_radius,
:connector_negative_radius => connector_negative_radius,
}

puts "\n\n"
derived_dimentions.sort_by{ |k,v| v }.reverse.each { |k,v| puts "#{k}: #{v*100} mm"  }
puts "\n\n"

`rm ./#{DB}`
`#{mged} 'units dm'` # set mged's units to decimeter 

Dodecahedron.edges.each_with_index do |edge,index| #insert the 30 connectors
	edge = edge.map{|e|e *scale_factor}
	a = average(*edge.map{|e|e}) # the ideal location of the connector
	a = a * joint_nudge # nudge the connector closer to the center

	b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half connector
	b = b*0.1 # scale the length of the connecter, this is buggy when scale_factor is adjusted
	`#{mged} 'in connector1_#{index} rcc #{a.mged} #{b.mged} #{connector_radius}'` 
	`#{mged} 'in connector_negative1_#{index} rcc #{a.mged} #{b.mged} #{connector_negative_radius}'` 

	b = Vector[0,0,0]-b # point the vector in the opposite direction 
	`#{mged} 'in connector2_#{index} rcc #{a.mged} #{b.mged} #{connector_radius}'` 
	`#{mged} 'in connector_negative2_#{index} rcc #{a.mged} #{b.mged} #{connector_negative_radius}'` 
end
	`#{mged} 'r joints u #{(0..29).map{|index| " connector1_#{index} u connector2_#{index}"}.join(" u ")}'` #combine the pieces
	`#{mged} 'r joints_negative u #{(0..29).map{|index| " connector_negative1_#{index} u connector_negative2_#{index}"}.join(" u ")}'` #combine the pieces



Dodecahedron.icosahedron.each_with_index do |v,index| # draw the 12 tori
	v = v*scale_factor
	`#{mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in torus_negative#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in cylinder_knockout#{index} rcc #{v.mged} #{v.mged} #{torus_ring_size+torus}.'` #this removed the face of the torus so we can install coils
	`#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} - cylinder_knockout#{index} - joints_negative'` #combine the pieces
	# `#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} '`
end
# `#{mged} 'r polywell_tori u #{(0...12).map{|index| "torus_shell#{index}"}.join(" u ")}'` 

	`#{mged} 'r joints2 u joints - #{(0..11).map{|index| "torus_negative#{index}"}.join(" - ")} '` #remove the torus negative from the joints


`#{mged} 'r polywell u #{(0..11).map{|index| "torus_shell#{index}"}.join(" u ")} u joints2 '` #union all the parts into a sings polywell object
# `g-stl -o dodeca_holow.stl  test3.g polywell`


