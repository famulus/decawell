require 'test/unit'

class MgedControllerTest < Test::Unit::TestCase
	
	def test_truth
		assert true # this should never fail!
	end

	def test_mged
		assert `which mged`.include?("mged") #ensure that mged is installed
	end
	
	
	
	

end