require 'matrix'


phi = (1+Math.sqrt(5))/2

dodecahedron_vertices = Matrix[

	[+1,+1,+1],
	[+1,+1,-1],
	[+1,-1,-1],
	[+1,-1,+1],
	[-1,-1,-1],
	[-1,+1,+1],
	[-1,+1,-1],
	[-1,-1,+1],
	[0, +1/phi,+phi],
	[0, +1/phi,-phi],
	[0, -1/phi,+phi],
	[0, -1/phi,-phi],
	[+1/phi, +phi, 0],
	[+1/phi, -phi, 0],
	[-1/phi, +phi, 0],
	[-1/phi, -phi, 0],
	[+phi, 0, +1/phi],
	[+phi, 0, -1/phi],
	[-phi, 0, +1/phi],
	[-phi, 0, -1/phi]

]

icosahedron = Matrix[
	[0, +1, +phi],
	[0, +1, -phi],
	[0, -1, +phi],
	[0, -1, -phi],
	[+1, +phi, 0],
	[+1, -phi, 0],
	[-1, +phi, 0],
	[-1, -phi, 0],
	[+phi, 0, +1],
	[+phi, 0, -1],
	[-phi, 0, +1],
	[-phi, 0, -1]
]

DB = "test3.g"
mged ="/usr/brlcad/bin/mged -f -c  #{DB} "
torus = 0.125
torus_negative = 0.90 * torus
torus_ring_size = 1

`rm #{DB}`

icosahedron.row_vectors().each_with_index do |v,index|
	`#{mged} 'in torus#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus}'`
	`#{mged} 'in torus_negative#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus_negative}'`
	`#{mged} 'in cylinder_knockout#{index} rcc #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size* 1.2}.'`
	`#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} - cylinder_knockout#{index}'`
end
`#{mged} 'r polywell_tori u #{(0...12).map{|index| "torus_shell#{index}"}.join(" u ")}'` 


