require 'Matrix'
module Geometry

	def cross_product(v1,v2)
		Vector[(v1[1]*v2[2] - v1[2]*v2[1]),(v1[2]*v2[0] - v1[0]*v2[2]), (v1[0]*v2[1] - v1[1]*v2[0])]
	end

	def average(*args)
		# puts args.size
		# puts args.inspect
		# Vector[(v1[0]+v2[0]/2),(v1[1]+v2[1]/2),(v1[2]+v2[2]/2)]
		v = args.first
		args.each_with_index do |vector,index|
			v = v+vector unless index == 0
			
		end
		v*(1/(args.size).to_f)
	end


	PHI = (1+Math.sqrt(5))/2

class Dodecahedron
	
	def self.vertices 
		Matrix[

			[+1,+1,+1],
			[+1,+1,-1],
			[+1,-1,-1],
			[+1,-1,+1],
			[-1,-1,-1],
			[-1,+1,+1],
			[-1,+1,-1],
			[-1,-1,+1],
			[0, +1/PHI,+PHI],
			[0, +1/PHI,-PHI],
			[0, -1/PHI,+PHI],
			[0, -1/PHI,-PHI],
			[+1/PHI, +PHI, 0],
			[+1/PHI, -PHI, 0],
			[-1/PHI, +PHI, 0],
			[-1/PHI, -PHI, 0],
			[+PHI, 0, +1/PHI],
			[+PHI, 0, -1/PHI],
			[-PHI, 0, +1/PHI],
			[-PHI, 0, -1/PHI]

		].row_vectors()
	end
	
	def self.faces
		face_indexes = [[0, 1, 12, 16, 17], [0, 3, 8, 10, 16], [0, 5, 8, 12, 14], [1, 2, 9, 11, 17], [1, 6, 9, 12, 14], [2, 3, 13, 16, 17], [2, 4, 11, 13, 15], [3, 7, 10, 13, 15], [4, 6, 9, 11, 19], [4, 7, 15, 18, 19], [5, 6, 14, 18, 19], [5, 7, 8, 10, 18]]
		face_indexes.map { |f| f.map{|v|vertices[v]}  }
	end
	
	def self.icosahedron
		faces.map do |face|
			midpoint  = average(*face.map { |v|v  })
		end
	end
	
	def self.edges
		edges =[[18, 19], [16, 17], [13, 15], [12, 14], [9, 11], [8, 10], [0, 16], [0, 8], [7, 15], [7, 10], [6, 19], [0, 12], [6, 14], [6, 9], [5, 18], [7, 18], [5, 14], [5, 8], [4, 19], [4, 15], [4, 11], [3, 16], [3, 13], [3, 10], [2, 17], [2, 13], [1, 9], [2, 11], [1, 17], [1, 12]]
		edges.map { |f| f.map{|v|vertices[v]} }
	end


end


	def intersection(u0,u1,t0,t1) # find intersection of line segment u0u1 and t0t1 in 3D

		u = 
		(( u0[1] - t0[1] )*( t1[0] - t0[0]) - ( u0[0] - t0[0] )*( t1[1] - t0[1] ))   / 
		(( u0[0] - u1[0] )*( t1[1] - t0[1]) - ( u1[1] - u0[1] )*( t1[0] - t0[0] ))

		Vector[
			(u*(u1[0]-u0[0]) + u0[0]),
			(u*(u1[1]-u0[1]) + u0[1]),
			(u*(u1[2]-u0[2]) + u0[2])
		]
		# Vector[
		# 	 (((b[0]-a[0]) + a[0]-c[0])/(d[0]-c[0])),
		# 	 (((b[1]-a[1]) + a[1]-c[1])/(d[1]-c[1])),
		# 	 (((b[2]-a[2]) + a[2]-c[2])/(d[2]-c[2]))
		# 	]
		#  det=Matrix[[a[0],a[1],a[2]] ,[b[0],b[1],b[2]] ,[c[0],c[1],c[2]]].det
		# detx=Matrix[[d[0],d[1],d[2]] ,[b[0],b[1],b[2]] ,[c[0],c[1],c[2]]].det
		# dety=Matrix[[a[0],a[1],a[2]] ,[d[0],d[1],d[2]] ,[c[0],c[1],c[2]]].det
		# detz=Matrix[[a[0],a[1],a[2]] ,[b[0],b[1],b[2]] ,[d[0],d[1],d[2]]].det
		# 
		# if (d[0]==0 && d[1]==0 && d[2]==0 && det==0)                  
		# 	puts "Infinite Solutions"                               
		# elsif (d[0]==0 && d[1]==0 && d[2]==0 && det!=0)               
		# 	return Vector[0,0,0]                                    
		# elsif (det!=0)                                            
		# 	return Vector[(detx/det), (dety/det), (detz/det)]       
		# elsif (det==0 && detx==0 && dety==0 && detz==0)           
		# 	puts "Infinite Solutions"                               
		# else	                                                    
		# 	puts "No Solutions"                                     
		# end                                                       
	end

end
