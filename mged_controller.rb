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
	[0, +1, +phi]  ,
	[0, +1, -phi]  ,
	[0, -1, +phi]  ,
	[0, -1, -phi]  ,
[+1, +phi, 0]    ,
[+1, -phi, 0]    ,
[-1, +phi, 0]    ,
[-1, -phi, 0]    ,
[+phi, 0, +1]    ,
[+phi, 0, -1]    ,
[-phi, 0, +1]    ,
[-phi, 0, -1]    
	]

`rm /Users/mark/Documents/edge/lib/test3.g`
icosahedron.row_vectors().each_with_index do |v,index|
`/usr/brlcad/bin/mged -f -c  test3.g 'in torus#{index}.s tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} 1.0 0.125'`
end
# `/usr/brlcad/bin/mged -f /Users/mark/Documents/edge/lib/test3.g`
