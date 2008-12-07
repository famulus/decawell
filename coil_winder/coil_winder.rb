class CoilWinder < ArduinoSketch
	require '../geometry.rb'
	# require '../mged_controller.rb'
scale_factor = 140 # global scaling factor

torus_negative = 5.831
coil_wire_diameter = 2.053  # mm this 12 gauge AWS
torus_ring_size = 0.601 *scale_factor


	coil = Geometry::Coil.new((torus_negative*2), coil_wire_diameter, torus_ring_size)

	
	output_pin 13, :as => :led

	def loop
		blink led, 500
	end
end
