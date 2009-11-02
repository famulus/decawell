require 'ruby-units'
require 'geometry'
include Geometry
require 'facets'


parts = %w(chassis lids)

DB = "decawell.g"
mged ="mged -c  #{DB} "

mm = Unit("mm")
amp = Unit("amp")
ohm = Unit("ohm")


scale_factor = 37 # global scaling factor

ribbon_width = 4.2
ribbon_thickness = 0.3 # mm 
turns = 12
minimum_wall_thickness = 2 #mm


outside_radius = (Cube.vertices[0].r) *scale_factor #the distance from the center of the machine to the furthest edge of the core
torus_midplane_radius = (Cube.octahedron[0].r) * scale_factor #distance from the center of the machine to the center of a coil

edge = Cube.edges.first.map{|e|e *scale_factor} # find first edge
a = average(*edge.map{|e|e}) # find midpoint of edge
b = average(*Cube.faces_for_edge.first.first.map{|e|e *scale_factor}) #find center of abutting face
puts "max ring"
puts max_torus = (a-b).r

torus_ring_size = max_torus/1.305 #0.700 *scale_factor # the main torus shape
torus = 0.17 *scale_factor 
torus_negative = 0.72 * torus 
joint_radius = (ribbon_width/2) + (minimum_wall_thickness)
joint_negative_radius = (ribbon_width/2) + 0.05
joint_nudge = 0.87 # this is a percentage scaling of the vector defining the ideal joint location
joint_nudge_length = 0.16
coil_wire_diameter = 1.1  # mm test wire
channel_thickness = (ribbon_thickness*turns)+1
tolerance_distance = 0.01
drive_amps = 80



# Ampère's force law calculations  http://en.wikipedia.org/wiki/Ampère%27s_force_law
magnetic_constant = (4*Math::PI * (10.0**-7)) * Unit("newton/ampere**2")
magnetic_force_constant = magnetic_constant / (2*Math::PI)
seperation_of_wires = (torus_midplane_radius*mm) >> Unit("m") # in m
coil_force_per_meter = magnetic_force_constant * ((drive_amps**2)/seperation_of_wires)




derived_dimentions = {
	:outside_radius => outside_radius,
	:torus_midplane_radius => torus_midplane_radius,
	:torus_radius => torus_ring_size,
	:torus_tube_radius => torus,
	:torus_tube_wall_thickness => torus-torus_negative,
	:torus_tube_hollow_radius => torus_negative,
	:joint_radius => joint_radius,
	:joint_negative_radius => joint_negative_radius,
	:donut_exterier_radius => torus_ring_size +torus ,
	:donut_hole_radius => torus_ring_size -torus,
}


amperes_force = {
	:magnetic_constant => magnetic_constant, 
	:magnetic_force_constant => magnetic_force_constant, 
	:seperation_of_wires => seperation_of_wires, 
	:coil_force_per_meter => coil_force_per_meter, 


}



# Print the dimentions and properties of the current magrid to standard output.
puts "\n\n"
derived_dimentions.select{|k,v| v.class != Unit}.sort_by{|k,v| v}.reverse.each { |k,v| puts "#{k}: #{v} mm"  }
puts "\n\n"
[amperes_force].each do |topic|
	puts "\n\n"
	topic.select{|k,v| v.class == Unit}.each { |k,v| puts "#{k}: #{v}"  }
	puts "\n\n"
end


`rm -f ./#{DB.gsub(".g","")}.*`
`#{mged} 'units mm'` # set mged's units to decimeter 
`#{mged} 'tol dist #{tolerance_distance}'` #  


if true #parts.include?("chassis")
	
	Cube.octahedron.each_with_index do |v,index| # draw the 12 tori
		v = v*scale_factor
		#determin major axis depending on coil proportions
		major_minor = [((ribbon_width/2+minimum_wall_thickness)),((channel_thickness/2)+minimum_wall_thickness)]
		major_minor = major_minor.reverse if major_minor[0] < major_minor[1]
		
		`#{mged} 'in torus#{index} eto #{v.mged} #{v.mged} #{torus_ring_size}  #{((v.normal)*major_minor[0]).mged}   #{major_minor[1]} '` #the eto solid
		`#{mged} 'in torus_negative_outer#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size+(channel_thickness/2)} '` #the outside radious of the ribbon channel
		`#{mged} 'in torus_negative_inner#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size-(channel_thickness/2)}'` #the inside radious of the ribbon channel
		`#{mged} 'comb torus_negative#{index}.c u torus_negative_outer#{index} - torus_negative_inner#{index} '` #this hollow center of the torus
		`#{mged} 'in lid_knockout#{index} rcc #{v.mged} #{(v.normal*torus ).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
	end
	Cube.edges.each_with_index do |edge,index| #insert the 30 joints
		edge = edge.map{|e|e *scale_factor} # scale the edges
		a = average(*edge.map{|e|e}) # the ideal location of the joint
		a = a * joint_nudge # nudge the joint closer to the center
		b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
		b = b.normal*scale_factor* joint_nudge_length # get the unit vector for this direction and scale
		`#{mged} 'in joint_#{index} rcc #{(a+b).mged} #{(b.inverse*2).mged} #{joint_radius}'` 
		`#{mged} 'in joint_negative_#{index} rcc #{(a+b).mged} #{(b.inverse*2).mged} #{joint_negative_radius}'` 
	end
	`#{mged} 'comb solid.c u #{(0...Cube.edges.size).map{|index| " joint_#{index} "}.join(" u ")} u #{(0..5).map{|index| "torus#{index}"}.join(" u ")}'` #combine the pieces
	`#{mged} 'comb negative_form.c u #{(0...Cube.edges.size).map{|index| " joint_negative_#{index}  "}.join(" u ")} u #{(0..5).map{|index| "torus_negative#{index}.c u lid_knockout#{index}"}.join(" u ") } '` #combine the pieces
	`#{mged} 'r chassis u solid.c - negative_form.c'` #combine the pieces
end

if parts.include?("cutout")
	cutout_vector = Dodecahedron.icosahedron[0]
	`#{mged} 'in cutout_shape rcc #{((cutout_vector*scale_factor*0.8).mged)} #{(cutout_vector*scale_factor).mged} #{outside_radius}'` #this hollow center of the torus
	`#{mged} 'comb cutout u chassis + cutout_shape'` #combine the pieces

end



if parts.include?("lids") 
	(0..0).map do |index| # originallty we needed many lids, but now we only need one
		index1 = index+1
		v = Cube.octahedron.first
		v = v*scale_factor

		`#{mged} 'in torus_negative_outer#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size+(channel_thickness/2)} '` #the outside radious of the ribbon channel
		`#{mged} 'in torus_negative_inner#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size-(channel_thickness/2)}'` #the inside radious of the ribbon channel
		`#{mged} 'comb lid_torus_negative#{index} u torus_negative_outer#{index} -  torus_negative_inner#{index} '` #this hollow center of the torus
		`#{mged} 'in lid_lid_knockout#{index} rcc #{v.mged}  #{(v*2).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
	end
			`#{mged} 'r lids u #{(0..0).map{|index| "torus#{index} - lid_torus_negative#{index} - lid_lid_knockout#{index}"}.join(" u ")}'` #combine the pieces

end


if parts.include?("lid_with_access")
	`#{mged} 'in lid_with_access_torus#{index} tor #{(step*index1).mged} #{(step*index1).mged}  #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in lid_with_access_torus_negative#{index} tor #{(step*index1).mged}  #{(step*index1).mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in lid_with_access_knockout#{index} rcc #{(step*index1).mged}  #{((step.normal)*torus).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
end


`rm -f ./temp/*` #clear out temp files
parts.each do |part|

part_with_git_hash = "#{`git rev-parse HEAD`.chomp}_#{part}"	#give the STL output a uniq ID based on git repo hash

# this block prepares a snapshot picture of the part
`cat <<EOF | mged -c #{DB}
B #{part}
ae 135 -35 180
set perspective 20
zoom .30
saveview ./temp/#{part}.rt
EOF`
	
`./temp/#{part}.rt -s1024` # calling the .rt file outputs a .pix file
`mv #{part}.rt.pix ./temp/#{part}.rt.pix` # move this file to the temp directory
`pix-png -s1024 < ./temp/#{part}.rt.pix > ./parts/#{part_with_git_hash}.png` #generate a png from the rt.pix file
`open ./parts/#{part_with_git_hash}.png` # open the png in preview.app


`g-stl -a #{tolerance_distance} -D #{tolerance_distance} -o ./parts/#{part_with_git_hash}.stl #{DB} #{part}` #this outputs the stl file for the part

#this block convers the STL from the previous step back into native BRL-CAD format, and then outputs a snapshot
`stl-g ./parts/#{part_with_git_hash}.stl ./temp/#{part}_proof.g`
`cat <<EOF | mged -c ./temp/#{part}_proof.g
B all
ae 135 -35 180
set perspective 20
zoom .30
saveview ./temp/#{part}_proof.rt
EOF`
	
`./temp/#{part}_proof.rt -s1024`
`mv #{part}_proof.rt.pix ./temp/#{part}_proof.rt.pix` # move this file to the temp directory

`pix-png -s1024 < ./temp/#{part}_proof.rt.pix > ./temp/#{part}_proof.png` #generate a png from the rt file
`open ./temp/#{part}_proof.png` # open the png in preview.app


end
