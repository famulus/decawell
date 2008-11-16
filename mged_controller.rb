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
joint_radius = torus * 0.73
joint_negative_radius = joint_radius * 0.35
joint_nudge = 0.863 # this is a percentage scaling of the vector defining the ideal joint location

derived_dimentions = {
	:outside_radius => (Dodecahedron.vertices[0].r) ,
	:torus_midplane_radius => (Dodecahedron.icosahedron[0].r),
	:torus_radius => torus_ring_size,
	:torus_tube_radius => torus,
	:torus_tube_wall_thickness => torus-torus_negative,
	:torus_tube_hollow_radius => torus_negative,
	:joint_radius => joint_radius,
	:joint_negative_radius => joint_negative_radius,
}

puts "\n\n"
derived_dimentions.sort_by{ |k,v| v }.reverse.each { |k,v| puts "#{k}: #{v*100} mm"  }
puts "\n\n"

`rm ./#{DB}`
`#{mged} 'units dm'` # set mged's units to decimeter 

Dodecahedron.icosahedron.each_with_index do |v,index| # draw the 12 tori
	v = v*scale_factor
	`#{mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in torus_negative#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in lid_knockout#{index} rcc #{v.mged} #{v.mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
end

Dodecahedron.edges.each_with_index do |edge,index| #insert the 30 joints
	edge = edge.map{|e|e *scale_factor} # scale the edges
	a = average(*edge.map{|e|e}) # the ideal location of the joint
	a = a * joint_nudge # nudge the joint closer to the center
	b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
	b = b*0.25* scale_factor
	`#{mged} 'in joint1_#{index} rcc #{a.mged} #{b.mged} #{joint_radius}'` 
	`#{mged} 'in joint_negative1_#{index} rcc #{a.mged} #{b.mged} #{joint_negative_radius}'` 
	b = Vector[0,0,0]-b # point the vector in the opposite direction 
	`#{mged} 'in joint2_#{index} rcc #{a.mged} #{b.mged} #{joint_radius}'` 
	`#{mged} 'in joint_negative2_#{index} rcc #{a.mged} #{b.mged} #{joint_negative_radius}'` 
end

`#{mged} 'r solid u #{(0..29).map{|index| " joint1_#{index} u joint2_#{index}"}.join(" u ")} u #{(0..11).map{|index| "torus#{index}"}.join(" u ")}'` #combine the pieces
`#{mged} 'r negative_form u #{(0..29).map{|index| " joint_negative1_#{index} u joint_negative2_#{index}"}.join(" u ")} u #{(0..11).map{|index| "torus_negative#{index} u lid_knockout#{index}"}.join(" u ") } '` #combine the pieces
`#{mged} 'r polywell u solid - negative_form'` #combine the pieces



# `g-stl -o dodeca_holow.stl  test3.g polywell`


