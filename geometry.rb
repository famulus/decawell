require 'Matrix'

class Vector
	def mged #to mged format
		s = self.to_a
		s.map{|v| v}.join(" ")
	end

	def normal #find the normal of Vector
		v = []
		self.map do |p|
			v << (p/Math.sqrt( self.to_a.map{|q| q**2 }.inject(0){|sum, n| sum +n } ))
		end
		Vector[*v]
	end	
	
	def inverse # find the inverse of Vector
		Vector[0,0,0] - self
	end
	
	def self.average(*args) # average two or more Vectors
		v = args.first
		args.each_with_index do |vector,index|
			raise TypeError unless vector.is_a? Vector # this funtion only works on Vectors!
			v = v+vector unless index == 0
		end
		v*(1/(args.size).to_f)
	end
	
end






module Geometry

	PHI = (1+Math.sqrt(5))/2


	def cross_product(v1,v2) # cross prouct of two Vectors
		Vector[(v1[1]*v2[2] - v1[2]*v2[1]),(v1[2]*v2[0] - v1[0]*v2[2]), (v1[0]*v2[1] - v1[1]*v2[0])]
	end


	class Cube
		
		def self.vertices 
			Matrix[
				[-1,-1,-1],
				[-1,-1,1],
				[-1,1,-1],
				[-1,1,1],
				[1,-1,-1],
				[1,-1,1],
				[1,1,-1],
				[1,1,1]
				].row_vectors()
			end
			
			
			def self.faces_indices
				[[8 , 4 , 2 , 6],
				[8 , 6 , 5 , 7],
				[8 , 7 , 3 , 4],
				[4 , 3 , 1 , 2],
				[1 , 3 , 7 , 5],
				[2 , 1 , 5 , 6]].map{|a|a.map{|b|b-1}} #shift for a zero based index
			end
			
			
			def self.edge_indices
				[[1,2],
				[1,3],
				[1,5],
				[2,4],
				[2,6],
				[3,4],
				[3,7],
				[4,8],
				[5,6],
				[5,7],
				[6,8],
				[7,8]].map{|a|a.map{|b|b-1}} #shift for a zero based index
			end


			def self.octahedron
				faces.map do |face|
					midpoint  = Vector.average(*face.map { |v|v  })
				end
			end


			def self.faces
				self.faces_indices.map { |f| f.map{|v|vertices[v]}  }
			end


			def self.edges
				self.edge_indices.map { |f| f.map{|v|vertices[v]} }
			end


			def self.faces_for_edge
				self.faces_for_edge_indices.map { |a|a.map { |b| b.map { |c| self.vertices[c]  }}  }
			end


			def self.faces_for_edge_indices
				self.edge_indices.map do |edge|
					self.faces_indices.select{|face| face.include?(edge[0]) && face.include?(edge[1]) }
				end
			end

		end


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

		def self.faces_indices
			[[0, 1, 12, 16, 17], [0, 3, 8, 10, 16], [0, 5, 8, 12, 14], [1, 2, 9, 11, 17], [1, 6, 9, 12, 14], [2, 3, 13, 16, 17], [2, 4, 11, 13, 15], [3, 7, 10, 13, 15], [4, 6, 9, 11, 19], [4, 7, 15, 18, 19], [5, 6, 14, 18, 19], [5, 7, 8, 10, 18]]
		end
		def self.edge_indices 
			[[18, 19], [16, 17], [13, 15], [12, 14], [9, 11], [8, 10], [0, 16], [0, 8], [7, 15], [7, 10], [6, 19], [0, 12], [6, 14], [6, 9], [5, 18], [7, 18], [5, 14], [5, 8], [4, 19], [4, 15], [4, 11], [3, 16], [3, 13], [3, 10], [2, 17], [2, 13], [1, 9], [2, 11], [1, 17], [1, 12]]
		end

		def self.faces_for_edge_indices
			self.edge_indices.map do |edge|
				self.faces_indices.select{|face| face.include?(edge[0]) && face.include?(edge[1]) }
			end
		end

		def self.faces_for_edge
			self.faces_for_edge_indices.map { |a|a.map { |b| b.map { |c| self.vertices[c]  }}  }
		end

		def self.faces
			self.faces_indices.map { |f| f.map{|v|vertices[v]}  }
		end

		def self.icosahedron
			faces.map do |face|
				midpoint  = Vector.average(*face.map { |v|v  })
			end
		end

		def self.edges
			self.edge_indices.map { |f| f.map{|v|vertices[v]} }
		end

	end
end

