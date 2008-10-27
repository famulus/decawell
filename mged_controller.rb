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

def cross_product(v1,v2)
	Vector[(v1[1]*v2[2] - v1[2]*v2[1]),(v1[2]*v2[0] - v1[0]*v2[2]), (v1[0]*v2[1] - v1[1]*v2[0])]
end

def average(v1,v2)
	Vector[(v1[0]+v2[0]/2),(v1[1]+v2[1]/2),(v1[2]+v2[2]/2)]
end

def intersection(a,b,c,d) # find intersection of line segment ab and cd in 3D
	 det=Matrix[[a[0],a[1],a[2]] ,[b[0],b[1],b[2]] ,[c[0],c[1],c[2]]].det
	detx=Matrix[[d[0],d[1],d[2]] ,[b[0],b[1],b[2]] ,[c[0],c[1],c[2]]].det
	dety=Matrix[[a[0],a[1],a[2]] ,[d[0],d[1],d[2]] ,[c[0],c[1],c[2]]].det
	detz=Matrix[[a[0],a[1],a[2]] ,[b[0],b[1],b[2]] ,[d[0],d[1],d[2]]].det

	if (d[0]==0 && d[1]==0 && d[2]==0 && det==0)                  
		puts "Infinite Solutions"                               
	elsif (d[0]==0 && d[1]==0 && d[2]==0 && det!=0)               
		return Vector[0,0,0]                                    
	elsif (det!=0)                                            
		return Vector[(detx/det), (dety/det), (detz/det)]       
	elsif (det==0 && detx==0 && dety==0 && detz==0)           
		puts "Infinite Solutions"                               
	else	                                                    
		puts "No Solutions"                                     
	end                                                       
end


DB = "test3.g"
mged ="/usr/brlcad/bin/mged -f -c  #{DB} "
torus = 0.125
torus_negative = 0.90 * torus
torus_ring_size = 1

`rm #{DB}`

icosahedron.row_vectors().each_with_index do |v,index|
	`#{mged} 'in torus#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus}'`
	`#{mged} 'in torus_negative#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus_negative}'`
	# `#{mged} 'in cylinder_knockout#{index} rcc #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size* 1.2}.'`
	`#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} - cylinder_knockout#{index}'`
	`#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} '`
end
`#{mged} 'r polywell_tori u #{(0...12).map{|index| "torus_shell#{index}"}.join(" u ")}'` 


puts cross_product(Vector[1,2,3],Vector[4,5,6])

segments = []
icosahedron.row_vectors().each_with_index do |v,index|
	icosahedron.row_vectors().each_with_index do |vin,index_in|
		h = vin -v
		i = v -vin
		if h.r == 2 && i.r ==2 # only render the outer most vertices
			# `#{mged} 'in line#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{h[0]} #{h[1]} #{h[2]} 0.1'` 
			puts "cross_product#{ a =cross_product(h,v)}"
			puts "cross_productb#{ b =cross_product(v,a)}"
			puts "cross_productc#{ c =cross_product(i,vin)}"
			puts "cross_productc#{ d =cross_product(vin,c)}"
			b =b * 0.25
			d =d * 0.25
			# `#{mged} 'in dot#{index}_#{index_in} sph #{b[0]} #{b[1]} #{b[2]} 0.1'` 
			# `#{mged} 'in line2#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{a[0]} #{a[1]} #{a[2]} 0.1'` 
			# `#{mged} 'in line_right_#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{b[0]} #{b[1]} #{b[2]} 0.01'` 
			# `#{mged} 'in line_left_#{index}_#{index_in} rcc #{vin[0]} #{vin[1]} #{vin[2]} #{d[0]} #{d[1]} #{d[2]} 0.01'` 
			e = intersection(v,b+v,vin,d+vin)
			puts "OKOK:#{e}"
			# `#{mged} 'in dot#{index}_#{index_in} sph #{e[0]} #{e[1]} #{e[2]} 0.5'`  rescue nil
		end

	end
end

segments.each_with_index do |seg,index|
end

# `#{mged} 'in cutaway rcc 1 1 1  2 2 2 3'`   #draw a cutaway sphere
# `#{mged} 'r cutaway1 u polywell_tori - cutaway'` 


# `/usr/brlcad/bin/mged -f ./test3.g `
