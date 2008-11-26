require 'geometry'
include Geometry
require 'facets'

# parts = %w(chassis lids bobbin_left bobbin_right)
parts = %w(bobbin_left bobbin_right)

DB = "decawell.g"
mged ="/usr/brlcad/rel-7.12.2/bin//mged -c  #{DB} "
scale_factor = 140 # global scaling factor
torus_ring_size = 0.601 *scale_factor
torus = 0.17 *scale_factor
torus_negative = 0.79 * torus

joint_radius = torus * 0.70
joint_negative_radius = joint_radius * 0.35
joint_nudge = 0.89 # this is a percentage scaling of the vector defining the ideal joint location
joint_nudge_length = 0.22
coil_wire_diameter = 2.053  # mm this 12 gauge AWS
coil = Coil.new(torus_negative*2, coil_wire_diameter, torus_ring_size)
drive_amps = 20000.0

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
	:wraps => coil.wraps,
	:coil_length => coil.coil_length,
	:drive_amps => drive_amps, 
	:ampere_turns => (drive_amps*coil.wraps), 
}

puts "\n\n"
derived_dimentions.sort_by{ |k,v| v }.reverse.each { |k,v| puts "#{k}: #{v} mm"  }
puts "\n\n"

`rm -f ./#{DB.gsub(".g","")}.*`
`#{mged} 'units mm'` # set mged's units to decimeter 
`#{mged} 'tol dist 0.0005'` # set mged's units to decimeter 

coil.grid.each {|row| puts row.map{|c|  c ? 1 : 0}.join(" ")}
# coil.grid.each {|row|  row.split(false).each{|a| puts a.size}}
coil.grid.each_with_index {|row,index| puts coil.wrap_radius_for_row(index)}


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
		b = b.normal*scale_factor* joint_nudge_length # get the unit vector for this direction and scale
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
	(0..0).map do |index| # originallty we needed many lids, but now we only need one
		index1 = index+1
		`#{mged} 'in lid_torus#{index} tor #{(step*index1).mged} #{(step*index1).mged}  #{torus_ring_size} #{torus}'` #the torus solid
		`#{mged} 'in lid_torus_negative#{index} tor #{(step*index1).mged}  #{(step*index1).mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
		`#{mged} 'in lid_lid_knockout#{index} rcc #{(step*index1).mged}  #{((step.normal)*torus).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
		
	end
			`#{mged} 'r lids u #{(0..0).map{|index| "lid_torus#{index} - lid_torus_negative#{index} - lid_lid_knockout#{index}"}.join(" u ")}'` #combine the pieces

end

# the bobbin 

if parts.include?("bobbin_left")
	offset = Vector[20,0,0]
	wall_thickness = (2.6) # mm
	shaft_radius = (6.35 ) /2.0
	shaft_length = (16 )
	screw_hole_radius = 2 #mm
	screw_hole_position_radius = (torus_ring_size - torus)*0.7 #mm
	notch_origin = shaft_radius -((shaft_radius * 2) - (5.8 )) 
	puts "notch_origin#{notch_origin}"
	puts "wall_thickness: #{wall_thickness}"
	`#{mged} 'in bobbin_torus tor 0 0 0 #{offset.mged} #{torus_ring_size} #{torus_negative+wall_thickness}'` #the torus solid
	`#{mged} 'in bobbin_negative tor 0 0 0  #{offset.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in bobbin_half rcc 0 0 0 #{(offset.normal*torus).mged} #{torus_ring_size}'` #this defines half the torus, so the bobin splits apart
	`#{mged} 'in support_plate rcc 0 0 0 #{(offset.normal*wall_thickness).mged} #{torus_ring_size-torus + wall_thickness  }'` #the plate to the shaft
	`#{mged} 'in shaft_negative rcc 0 0 0  #{(offset.normal*shaft_length).mged} #{shaft_radius  }'` #the plate to the shaft
	`#{mged} 'in shaft_notch rcc #{(Vector[0,notch_origin,0]).mged} #{Vector[0,shaft_length,0].mged}  #{shaft_length*1.2  }'` #the plate to the shaft

	`#{mged} 'in screw_hole rcc 0 #{(screw_hole_position_radius)} 0  #{(offset.normal*shaft_length).mged} #{screw_hole_radius}'` #the screw hole to hold the halves together
	`#{mged} 'in screw_hole2 rcc 0 0 #{screw_hole_position_radius}  #{(offset.normal*shaft_length).mged} #{screw_hole_radius}'` #the screw hole to hold the halves together
	`#{mged} 'mirror screw_hole screw_hole3 y'` #combine the pieces
	`#{mged} 'mirror screw_hole2 screw_hole4 z'` #combine the pieces

	`#{mged} 'in wire_access_notch rcc 0 #{torus_ring_size -torus_negative+5 } 0 #{(Vector[0,0,0] - Vector[0,torus_ring_size -torus_negative ,0]).normal*15} 3'` #combine the pieces


	`#{mged} 'r shaft_with_notch u screw_hole4 u screw_hole3 u screw_hole2 u screw_hole u shaft_negative - shaft_notch '` # form the shaft with notch
	`#{mged} 'r bobbin1 u support_plate - shaft_with_notch  u bobbin_torus + bobbin_half - bobbin_negative  '` # form the first half of the bobbin
	`#{mged} 'r bobbin_left u bobbin1 - wire_access_notch  '` # form the first half of the bobbin

	`cat <<EOF | mged -c #{DB}
	B bobbin	
	oed / bobbin/bobbin1/bobbin_torus	
	translate #{offset.mged}
	accept
EOF`
	
		`#{mged} 'mirror bobbin_left bobbin_right x'` #combine the pieces


# 	`cat <<EOF | mged -c #{DB}
# 	B bobbin	
# 	oed bobbin bobbin_twin
# 	translate #{(Vector[0,0,0] -offset).mged}
# 	accept
# EOF`


	# `#{mged} 'r bobbin_pair u bobbin  u bobbin_twin'` #combine the pieces
end

if parts.include?("lid_with_access")
	`#{mged} 'in lid_with_access_torus#{index} tor #{(step*index1).mged} #{(step*index1).mged}  #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in lid_with_access_torus_negative#{index} tor #{(step*index1).mged}  #{(step*index1).mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in lid_with_access_knockout#{index} rcc #{(step*index1).mged}  #{((step.normal)*torus).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
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
# `g-stl -a 0.005 -D 0.005 -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part
`g-stl -a 0.01 -D 0.01 -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part
`rm -f ./#{part}.rt `
`rm -f ./#{part}.rt.pix `
`rm -f ./#{part}.rt.log`
end
