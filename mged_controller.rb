require 'ruby-units'
require './geometry'
include Geometry
require 'facets'

def chassis # the chassis is the inner section of the magrid

	chassis_solids = []
	chassis_negatives = []

	Cube.octahedron.each_with_index do |v,index| # draw the 6 tori
		v = v*@scale_factor		
		`#{@mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{@torus_ring_size} #{@torus} '` #the torus solid
		chassis_solids << "torus#{index}"
		`#{@mged} 'in torus_negative#{index} tor #{v.mged} #{v.mged} #{@torus_ring_size+@torus} #{@torus*0.7} '` #the depression negative to hold the coils
		chassis_negatives << "torus_negative#{index}"

	end
	Cube.edges.each_with_index do |edge,index| #insert the  joints
		edge = edge.map{|e|e *@scale_factor} # scale the edges
		a = Vector.average(*edge.map{|e|e}) # the ideal location of the joint
		a = a * @joint_nudge # nudge the joint closer to the center
		b = cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
		b = b.normal*@scale_factor* @joint_nudge_length # get the unit vector for this direction and scale
		base = b*20
		`#{@mged} 'in joint_#{index} rcc #{(a+b).mged} #{(b.inverse*2).mged} #{@joint_radius}'`
		chassis_solids << "joint_#{index}"

		if [3,4,7,10].include?(index) # these are the joins that extend to become a base
			`#{@mged} 'in base_#{index} rcc #{(a+base).mged} #{(base.inverse).mged} #{@joint_radius}'` if [4,10].include?(index)
			`#{@mged} 'in base_#{index} rcc #{(a).mged} #{(base.inverse).mged} #{@joint_radius}'` if [3,7].include?(index)
			chassis_solids << "base_#{index}"
		end
		
	end
	
	base_vector = Cube.octahedron.first
	
	`#{@mged} 'in electron_gun_sphere sph #{(base_vector*@scale_factor*1.7).mged} 15'` #sphere to hold electron gun
	`#{@mged} 'in electron_gun_hollow rcc #{(base_vector*@scale_factor*1.7).mged} #{base_vector*18} 8'` #hollow to fit copper tube
	`#{@mged} 'in electron_gun_hollow_inverse rcc #{(base_vector*@scale_factor*1.5).mged} #{base_vector.inverse*18} 8'` #hollow to fit copper tube
	chassis_solids << "electron_gun_sphere"
	chassis_negatives << "electron_gun_hollow"
	chassis_negatives << "electron_gun_hollow_inverse"
	
	
	`#{@mged} 'comb solid.c u #{chassis_solids.map{|c| c }.join(" u ")}'` #combine the pieces
	
	`#{@mged} 'comb negative_form.c u #{chassis_negatives.map{|c|c }.join(" u ")}'` #combine the pieces
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
@joint_radius = 3

@outside_radius = (Cube.vertices[0].r) *@scale_factor #the distance from the center of the machine to the furthest edge of the core
@torus_midplane_radius = (Cube.octahedron[0].r) * @scale_factor #distance from the center of the machine to the center of a coil

edge = Cube.edges.first.map{|e|e *@scale_factor} # find first edge
a = Vector.average(*edge.map{|e|e}) # find midpoint of edge
b = Vector.average(*Cube.faces_for_edge.first.first.map{|e|e *@scale_factor}) #find center of abutting face
max_torus = (a-b).r

@torus_ring_size = max_torus/1.305 #0.700 *@scale_factor # the main torus shape
@torus = 0.14 *@scale_factor 
@joint_nudge = 0.84 # this is a percentage scaling of the vector defining the ideal joint location
@joint_nudge_length = 0.16



`#{@mged} 'units mm'` # set mged's units to millimeter 
`#{@mged} 'tol dist #{@tolerance_distance}'` #  set the global tolerance distance

`rm -f ./temp/*` #clear out temp files
chassis # generate the parts in mged

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
