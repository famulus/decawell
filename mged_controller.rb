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
torus = 0.125
torus_negative = 0.90 * torus
torus_ring_size = 1

`rm #{DB}`
# `/usr/brlcad/bin/mged -f -c  #{DB} 'kill -f * '`

icosahedron.row_vectors().each_with_index do |v,index|
	`/usr/brlcad/bin/mged -f -c  #{DB} 'in torus#{index}.t tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus}'`
	`/usr/brlcad/bin/mged -f -c  #{DB} 'in torus_negative#{index}.t tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus_negative}'`
	`/usr/brlcad/bin/mged -f -c  #{DB} 'in cylinder_knockout#{index} rcc #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size* 1.2}.'`
	`/usr/brlcad/bin/mged -f -c  #{DB} 'r torus_shell.r u torus#{index}.t - torus_negative#{index}.t - cylinder_knockout#{index} '`
end
# `/usr/brlcad/bin/mged -f /Users/mark/Documents/edge/lib/test3.g`
