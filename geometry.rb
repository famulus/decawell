require 'Matrix'

class Vector
	def mged
		s = self.to_a
		s.map{|v| v}.join(" ")
	end
	
	def normal
		v = []
		self.map do |p|
			v << (p/Math.sqrt( self.to_a.map{|q| q**2 }.inject(0){|sum, n| sum +n } ))
		end
		Vector[*v]
	end	
end

module Geometry
	class Coil
		
		
		def initialize
			

		end
		
		def wrap_radius_for_row(row = 0)
			
		end

		
		
		def rasterCircle( x0, y0, radius)
			
			@grid = (0..(radius*2)).to_a.map{|a|(0..(radius*2)).to_a.map{|b| 0}}
			
			f = 1 - radius
			ddF_x = 1
			ddF_y = -2 * radius
			x = 0
			y = radius

			@grid[x0][y0 + radius]   =1
			@grid[x0][ y0 - radius]  =1
			@grid[x0 + radius][ y0]  =1
			@grid[x0 - radius][ y0]  =1

			while(x < y) do
				if(f >= 0) 
					y -=1
					ddF_y += 2
					f += ddF_y
				end
				x +=1
				ddF_x += 2
				f += ddF_x       
				@grid[x0 + x][ y0 + y] =1
				@grid[x0 - x][ y0 + y] =1
				@grid[x0 + x][ y0 - y] =1
				@grid[x0 - x][ y0 - y] =1
				@grid[x0 + y][ y0 + x] =1
				@grid[x0 - y][ y0 + x] =1
				@grid[x0 + y][ y0 - x] =1
				@grid[x0 - y][ y0 - x] =1
			end
			@grid.each{|a|puts a.join(" ")}

		end
	end


	def cross_product(v1,v2)
		Vector[(v1[1]*v2[2] - v1[2]*v2[1]),(v1[2]*v2[0] - v1[0]*v2[2]), (v1[0]*v2[1] - v1[1]*v2[0])]
	end

	def average(*args)
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
end

