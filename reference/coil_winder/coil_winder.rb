# def tester(pic)
# 	
# end

class CoilWinder < ArduinoSketch
	require '../geometry.rb'
	# require '../mged_controller.rb'
	scale_factor = 140 # global scaling factor

	torus_negative = 5.831
	coil_wire_diameter = 2.053  # mm this 12 gauge AWS
	torus_ring_size = 0.601 *scale_factor


	# coil = Geometry::Coil.new((torus_negative*2), coil_wire_diameter, torus_ring_size)


  # output_pin 13, :as => :led
  software_serial 13 :as => :gps
  serial_begin

  def loop
    # digitalWrite(led, true)
    serial_print(gps.read)
  end



	# output_pin 6, :as => :led
	# output_pin 7, :as => :dir
	# # software_serial 6 :as => :step
	# # software_serial  7 :as => :dir
	# # serial_begin
	# 
	# 
	# 
	# def loop
	# 	# tester(9)
	# 	1.upto(1000) do
	# 		digitalWrite(led, true)
	# 		delay(2)
	# 		digitalWrite(led, false)
	# 		delay(2)
	# 	end
	# 	digitalWrite(dir, !(digitalRead(dir)))
	# 
	# 
	# end

end
