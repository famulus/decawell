require 'test/unit'
require 'geometry'
include Geometry

class GeometryTest < Test::Unit::TestCase

	# ____________________________________________
	#test extensions of the standard vector class


	def setup
		@v = Vector[1,1,1] #use a simple vector for testing.
	end


	def test_truth
		assert true # this should never fail!
	end


	def test_inverse
		assert_equal(@v,@v.inverse.inverse) # inverting a vector twice should return the original vector.
		assert_equal(@v.inverse,Vector[-1,-1,-1]) # explicitly check the inverse of Vector[1,1,1]
	end


	def test_normal
		v_unit = Vector[0,0,1]
		assert_equal(v_unit.normal,Vector[0,0,1]) # a unit vector is equal to it's normal
		assert_equal((v_unit*10).normal,Vector[0,0,1]) #test the normal of a scaled vector
	end


	def mged_test
		assert_equal(@v.mged,"1 1 1") #test formatting for the mged command
	end

	def test_average
		assert_equal(Vector.average(@v,@v.inverse),Vector[0,0,0]) #a vector averaged with it's inverse should produce Vector[0,0,0]
		assert_equal(Vector.average(@v,@v,@v,@v),@v ) # test more than two arguments to average
	end

	# ____________________________________________
	#test Geometry methods.

	def test_cross_product
		assert_equal((Geometry::cross_product(Vector[0,0,1],Vector[1,0,0])),Vector[0,1,0]) # test an explicit cross product
	end

	def test_PHI
		assert PHI #ensure this constant is available
	end


	# ____________________________________________
	#test the Cube class

	def test_vertices
		assert_equal(Cube.vertices.size,8) #test that the cube has 8 vertices
		assert_equal(Cube.faces_indices.size,6) #test that is has 6 faces
		assert_equal(Cube.edge_indices.size,12) # test that the cube has 12 edges
		assert_equal(Cube.octahedron.size,6) # test that the cube's dual octahedron has 6 vertices
		assert_equal(Cube.faces.size, 6) #test that the cube has 6 faces
		assert_equal(Cube.faces[0].size, 4) # test that a face has 4 vertices
		assert_equal(Cube.edges.size, 12) # test for 12 edges
		assert_equal(Cube.edges[0].size,2) # test that an edge has 2 vertices
		# assert_equal(Vector.average(Cube.vertices),Vector[0,0,0]) # not working, args seeing array as a single param to the method, not several params
	end


	# ____________________________________________
	#test the Dodecahedron class
	
	def test_vertices
		assert_equal(Dodecahedron.vertices.size,20) #test that the Dodecahedron has 20 vertices
		assert_equal(Dodecahedron.faces_indices.size,12) #test has 12 faces
		assert_equal(Dodecahedron.edge_indices.size,30) # test that the Dodecahedron has 30 edges
		assert_equal(Dodecahedron.icosahedron.size,12) # test that the Dodecahedron's dual icosahedron has 12 vertices
		assert_equal(Dodecahedron.faces.size, 12) #test that the Dodecahedron has 12 faces
		assert_equal(Dodecahedron.faces[0].size, 5) # test that a face has 5 vertices
		assert_equal(Dodecahedron.edges.size, 30) # test for 30 edges
		assert_equal(Dodecahedron.edges[0].size,2) # test that an edge has 2 vertices
	end



end