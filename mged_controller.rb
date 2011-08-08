require 'ruby-units'
require './geometry'
include Geometry
require 'facets'

def chassis # the chassis is the inner section of the magrid

	

	Cube.octahedron.each_with_index do |v,index| # draw the 6 tori
		v = v*@scale_factor		
		`#{@mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{@torus_ring_size} #{@torus} '` #the eto solid
		`#{@mged} 'in torus_negative#{index} tor #{v.mged} #{v.mged} #{@torus_ring_size+@torus} #{@torus*0.7} '` #the eto solid

	end
	Cube.edges.each_with_index do |edge,index| #insert the  joints
		edge = edge.map{|e|e *@scale_factor} # scale the edges
		a = Vector.average(*edge.map{|e|e}) # the ideal location of the joint
		a = a * @joint_nudge # nudge the joint closer to the center
		b = cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
		b = b.normal*@scale_factor* @joint_nudge_length # get the unit vector for this direction and scale
	end
			`#{@mged} 'in electron_gun_sphere sph #{(Cube.octahedron.first*@scale_factor*1.5).mged} 17'` #sphere to hold electron gun

	
	
	`#{@mged} 'comb solid.c u #{(0..5).map{|index| "torus#{index}"}.join(" u ")} u electron_gun_sphere'` #combine the pieces
	`#{@mged} 'comb negative_form.c u #{(0..5).map{|index| "torus_negative#{index}"  }.join(' u ')}'` #combine the pieces
	`#{@mged} 'r chassis u solid.c - negative_form.c'` #remove negative from positive
end









# ____________________________________________
#begin script





parts = %w(chassis )

DB = "./temp/decawell.g" # location of BRL-CAD database
@mged ="mged -c  #{DB} " # shorthand for sending a command to mged using the decawell database

# define some shortcuts
mm = Unit("mm")
amp = Unit("amp")
ohm = Unit("ohm")


@scale_factor = 37 # global scaling factor

@ribbon_width = 4.2
@ribbon_thickness = 0.3 # mm 
@turns = 2
@minimum_wall_thickness = 3 #mm


@outside_radius = (Cube.vertices[0].r) *@scale_factor #the distance from the center of the machine to the furthest edge of the core
@torus_midplane_radius = (Cube.octahedron[0].r) * @scale_factor #distance from the center of the machine to the center of a coil

edge = Cube.edges.first.map{|e|e *@scale_factor} # find first edge
a = Vector.average(*edge.map{|e|e}) # find midpoint of edge
b = Vector.average(*Cube.faces_for_edge.first.first.map{|e|e *@scale_factor}) #find center of abutting face
max_torus = (a-b).r

@torus_ring_size = max_torus/1.305 #0.700 *@scale_factor # the main torus shape
@torus = 0.14 *@scale_factor 
@torus_negative = 0.72 * @torus 
@joint_radius = (@ribbon_width/2) + (@minimum_wall_thickness)
@joint_negative_radius = (@ribbon_width/2) + 0.2
@joint_nudge = 0.84 # this is a percentage scaling of the vector defining the ideal joint location
@joint_nudge_length = 0.16
@coil_wire_diameter = 1.1  # mm test wire
@channel_thickness = (@ribbon_thickness*@turns)+1
@tolerance_distance = 0.01
@drive_amps = 80


@electron_gun_distance = @torus_midplane_radius *1.5 



# Ampère's force law calculations  http://en.wikipedia.org/wiki/Ampère%27s_force_law
magnetic_constant = (4*Math::PI * (10.0**(-7))) * Unit("newton/ampere**2")
magnetic_force_constant = magnetic_constant / (2*Math::PI)
seperation_of_wires = (@torus_midplane_radius*mm) >> Unit("m") # in m
coil_force_per_meter = magnetic_force_constant * ((@drive_amps**2)/seperation_of_wires)




derived_dimentions = {
	:outside_radius => @outside_radius,
	:torus_midplane_radius => @torus_midplane_radius,
	:torus_radius => @torus_ring_size,
	:torus_tube_radius => @torus,
	:torus_tube_wall_thickness => @torus-@torus_negative,
	:torus_tube_hollow_radius => @torus_negative,
	:joint_radius => @joint_radius,
	:joint_negative_radius => @joint_negative_radius,
	:donut_exterier_radius => @torus_ring_size +@torus ,
	:donut_hole_radius => @torus_ring_size -@torus,
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


`#{@mged} 'units mm'` # set mged's units to millimeter 
`#{@mged} 'tol dist #{@tolerance_distance}'` #  set the global tolerance distance

`rm -f ./temp/*` #clear out temp files
chassis # generate the parts in mged
# lid 

# this block prepares a snapshot picture of the part
def render_view(ae ="ae 135 -35 180", zoom = 0.3 )
end


parts.each do |part|

	part_with_git_hash = "#{`git rev-parse HEAD`.chomp}_#{part}"	#give the STL output a uniq ID based on git repo hash


views = [["ae 135 -35 180",0.3], ["ae -22 -30 -16",0.54],["ae 9.5316 21.1861 33.5715",0.5]]

views.each_with_index do |view,index|
`cat <<EOF | mged -c #{DB}
B #{part}
#{view[0]}
set perspective 20
zoom #{view[1]}
saveview ./temp/#{part}_#{index}.rt
EOF`

`./temp/#{part}_#{index}.rt -s1024` # calling the .rt file outputs a .pix file
`mv #{part}_#{index}.rt.pix ./temp/#{part}_#{index}.rt.pix` # move this file to the temp directory
`mv #{part}_#{index}.rt.log ./temp/#{part}_#{index}.rt.log` # move this file to the temp directory
`pix-png -s1024 < ./temp/#{part}_#{index}.rt.pix > ./parts/#{part_with_git_hash}_#{index}.png` #generate a png from the rt.pix file
`open ./parts/#{part_with_git_hash}_#{index}.png` # open the png in preview.app

end


# `g-stl -a #{@tolerance_distance} -D #{@tolerance_distance} -o ./parts/#{part_with_git_hash}.stl #{DB} #{part}` #this outputs the stl file for the part
# 
# #this block converts the STL from the previous step back into native BRL-CAD format, and then outputs a snapshot
# `stl-g ./parts/#{part_with_git_hash}.stl ./temp/#{part}_proof.g`
# `cat <<EOF | mged -c ./temp/#{part}_proof.g
# B all
# ae 135 -35 180
# set perspective 20
# zoom .30
# saveview ./temp/#{part}_proof.rt
# EOF`
# 
# `./temp/#{part}_proof.rt -s1024`
# `mv #{part}_proof.rt.pix ./temp/#{part}_proof.rt.pix` # move this file to the temp directory
# 
# `pix-png -s1024 < ./temp/#{part}_proof.rt.pix > ./temp/#{part}_proof.png` #generate a png from the rt file
# `open ./temp/#{part}_proof.png` # open the png in preview.app


end
