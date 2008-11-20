require 'geometry'
include Geometry
require 'facets'

# parts = %w(chassis bobbin_pair lids)
parts = %w(bobbin_pair)

DB = "test3.g"
mged ="/usr/brlcad/rel-7.12.2/bin//mged -c  #{DB} "
scale_factor = 140 # global scaling factor
torus_ring_size = 0.55 *scale_factor
torus = 0.22 *scale_factor
torus_negative = 0.83 * torus
joint_radius = torus * 0.70
joint_negative_radius = joint_radius * 0.35
joint_nudge = 0.863 # this is a percentage scaling of the vector defining the ideal joint location
coil_wire_diameter = 0.644  # dm
pixels_across = ((torus_negative*2) /coil_wire_diameter).round

derived_dimentions = {
	:outside_radius => (Dodecahedron.vertices[0].r) *scale_factor ,
	:torus_midplane_radius => (Dodecahedron.icosahedron[0].r) * scale_factor,
	:torus_radius => torus_ring_size,
	:torus_tube_radius => torus,
	:torus_tube_wall_thickness => torus-torus_negative,
	:torus_tube_hollow_radius => torus_negative,
	:joint_radius => joint_radius,
	:joint_negative_radius => joint_negative_radius,
	:donut_exterier_radius => torus_ring_size +torus ,
	:donut_hole_radius => torus_ring_size -torus,
	# :pixels_across => pixels_across,
	# :coil_wire_diameter => coil_wire_diameter,
}


# rasterCircle(pixels_across/2,pixels_across/2,pixels_across/2)


puts "\n\n"
puts "wire pixels:#{pixels_across}"
derived_dimentions.sort_by{ |k,v| v }.reverse.each { |k,v| puts "#{k}: #{v} mm"  }
puts "\n\n"

`rm -f ./#{DB.gsub(".g","")}.*`
`#{mged} 'units mm'` # set mged's units to decimeter 

if parts.include?("chassis")
	Dodecahedron.icosahedron.each_with_index do |v,index| # draw the 12 tori
		v = v*scale_factor
		`#{mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus}'` #the torus solid
		`#{mged} 'in torus_negative#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
		`#{mged} 'in lid_knockout#{index} rcc #{v.mged} #{(v.normal*torus ).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
	end
	Dodecahedron.edges.each_with_index do |edge,index| #insert the 30 joints
		edge = edge.map{|e|e *scale_factor} # scale the edges
		a = average(*edge.map{|e|e}) # the ideal location of the joint
		a = a * joint_nudge # nudge the joint closer to the center
		b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
		b = b.normal*scale_factor* 0.25 # get the unit vector for this direction and scale
		`#{mged} 'in joint1_#{index} rcc #{a.mged} #{b.mged} #{joint_radius}'` 
		`#{mged} 'in joint_negative1_#{index} rcc #{a.mged} #{b.mged} #{joint_negative_radius}'` 
		b = Vector[0,0,0]-b # point the vector in the opposite direction 
		`#{mged} 'in joint2_#{index} rcc #{a.mged} #{b.mged} #{joint_radius}'` 
		`#{mged} 'in joint_negative2_#{index} rcc #{a.mged} #{b.mged} #{joint_negative_radius}'` 
	end
	`#{mged} 'r solid u #{(0..29).map{|index| " joint1_#{index} u joint2_#{index}"}.join(" u ")} u #{(0..11).map{|index| "torus#{index}"}.join(" u ")}'` #combine the pieces
	`#{mged} 'r negative_form u #{(0..29).map{|index| " joint_negative1_#{index} u joint_negative2_#{index}"}.join(" u ")} u #{(0..11).map{|index| "torus_negative#{index} u lid_knockout#{index}"}.join(" u ") } '` #combine the pieces
	`#{mged} 'r chassis u solid - negative_form'` #combine the pieces
end


if parts.include?("lids")
	spacer = 40
	step = Vector[40,0,0]
	(0..11).map do |index|
		index1 = index+1
		`#{mged} 'in lid_torus#{index} tor #{(step*index1).mged} #{(step*index1).mged}  #{torus_ring_size} #{torus}'` #the torus solid
		`#{mged} 'in lid_torus_negative#{index} tor #{(step*index1).mged}  #{(step*index1).mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
		`#{mged} 'in lid_lid_knockout#{index} rcc #{(step*index1).mged}  #{((step.normal)*torus).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
		
	end
			`#{mged} 'r lids u #{(0..11).map{|index| "lid_torus#{index} - lid_torus_negative#{index} - lid_lid_knockout#{index}"}.join(" u ")}'` #combine the pieces

end

# the bobbin 

if parts.include?("bobbin_pair")
	offset = Vector[20,0,0]
	wall_thickness = (2.5) # mm
	shaft_radius = (6.35 ) /2.0
	shaft_length = (16 )
	screw_hole_radius = 2 #mm
	notch_origin = shaft_radius -((shaft_radius * 2) - (5.8 )) 
	puts "notch_origin#{notch_origin}"
	puts "wall_thickness: #{wall_thickness}"
	`#{mged} 'in bobbin_torus tor 0 0 0 #{offset.mged} #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in bobbin_negative tor 0 0 0  #{offset.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in bobbin_half rcc 0 0 0 #{(offset.normal*torus).mged} #{torus_ring_size}'` #this defines half the torus, so the bobin splits apart
	`#{mged} 'in support_plate rcc 0 0 0 #{(offset.normal*wall_thickness).mged} #{torus_ring_size-torus + wall_thickness  }'` #the plate to the shaft
	`#{mged} 'in shaft_negative rcc 0 0 0  #{(offset.normal*shaft_length).mged} #{shaft_radius  }'` #the plate to the shaft
	`#{mged} 'in shaft_notch rcc #{(Vector[0,notch_origin,0]).mged} #{Vector[0,shaft_length,0].mged}  #{shaft_length*1.2  }'` #the plate to the shaft

	`#{mged} 'r shaft_with_notch u shaft_negative - shaft_notch'` # form the shaft with notch
	`#{mged} 'r bobbin u support_plate - shaft_with_notch  u bobbin_torus + bobbin_half - bobbin_negative  '` # form the first half of the bobbin

	`cat <<EOF | mged -c #{DB}
	B bobbin	
	oed / bobbin/bobbin_torus
	
	translate #{offset.mged}
	accept
EOF`
	
		`#{mged} 'mirror bobbin bobbin_twin x'` #combine the pieces


# 	`cat <<EOF | mged -c #{DB}
# 	B bobbin	
# 	oed bobbin bobbin_twin
# 	translate #{(Vector[0,0,0] -offset).mged}
# 	accept
# EOF`


	`#{mged} 'r bobbin_pair u bobbin  u bobbin_twin'` #combine the pieces
end


parts.each do |part|

`cat <<EOF | mged -c #{DB}
B #{part}
ae 135 -35 180
set perspective 20
zoom .30
saveview #{part}.rt
EOF`
	
`./#{part}.rt -s1024`
`pix-png -s1024 < #{part}.rt.pix > #{part}.png`
`open ./#{part}.png`
# `g-stl -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part
`rm -f ./#{part}.rt `
`rm -f ./#{part}.rt.pix `
`rm -f ./#{part}.rt.log`
end
