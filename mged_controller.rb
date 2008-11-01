require 'matrix'
require 'geometry'
include Geometry

DB = "test3.g"
mged ="/usr/brlcad/rel-7.12.2/bin//mged -c  #{DB} "
torus = 0.125
torus_negative = 0.90 * torus
torus_ring_size = 1

`rm ./#{DB}`

icosahedron.row_vectors().each_with_index do |v,index|
	`#{mged} 'in torus#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus}'`
	# `#{mged} 'in torus_negative#{index} tor #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size} #{torus_negative}'`
	# `#{mged} 'in cylinder_knockout#{index} rcc #{v[0]} #{v[1]} #{v[2]} #{v[0]} #{v[1]} #{v[2]} #{torus_ring_size* 1.2}.'`
	# `#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} - cylinder_knockout#{index}'`
	# `#{mged} 'r torus_shell#{index} u torus#{index} - torus_negative#{index} '`
end
# `#{mged} 'r polywell_tori u #{(0...12).map{|index| "torus_shell#{index}"}.join(" u ")}'` 

icosahedron.row_vectors().each_with_index do |v,index|
	icosahedron.row_vectors().each_with_index do |vin,index_in|
		h = vin - v #vector connecting the point pairs
		i = v - vin #the inverse of h
		if h.r == 2 && i.r ==2 # only render the outer most vertices
			puts "index:#{index},index_in:#{index_in}"
			# `#{mged} 'in line#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{h[0]} #{h[1]} #{h[2]} 0.1'` #the icosohedron
			a =cross_product(h,v)
			b =cross_product(v,a) 

			c =cross_product(i,vin)
			d =cross_product(vin,c)

			b =b * 0.25 #shorten the vectors
			d =d * 0.25
			# `#{mged} 'in dot#{index}_#{index_in} sph #{b[0]} #{b[1]} #{b[2]} 0.1'` 
			# `#{mged} 'in line2#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{a[0]} #{a[1]} #{a[2]} 0.1'` 
			`#{mged} 'in line_right_#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{b[0]} #{b[1]} #{b[2]} 0.01'` 
			`#{mged} 'in line_left_#{index}_#{index_in} rcc #{vin[0]} #{vin[1]} #{vin[2]} #{d[0]} #{d[1]} #{d[2]} 0.01'` 
			
			e = intersection(v,v+b,vin,vin+d)
			# puts "OKOK:#{e}"
			# `#{mged} 'in dot#{index}_#{index_in} sph #{e[0]} #{e[1]} #{e[2]} 0.1'`  rescue nil
			`#{mged} 'in a_#{index}_#{index_in} sph #{v[0]} #{v[1]} #{v[2]} 0.1'`  rescue nil
			`#{mged} 'in b_#{index}_#{index_in} sph #{(b+v)[0]} #{(b+v)[1]} #{(b+v)[2]} 0.1'`  rescue nil
			`#{mged} 'in c_#{index}_#{index_in} sph #{vin[0]} #{vin[1]} #{vin[2]} 0.1'`  rescue nil
			`#{mged} 'in d_#{index}_#{index_in} sph #{(d+vin)[0]} #{(d+vin)[1]} #{(d+vin)[2]} 0.1'`  rescue nil
			break
		end                                                            
		break
	end
end

# `#{mged} 'in cutaway rcc 1 1 1  2 2 2 3'`   #draw a cutaway sphere
# `#{mged} 'r cutaway1 u polywell_tori - cutaway'` 


