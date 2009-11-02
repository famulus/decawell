class RadTest < ArduinoSketch

	# looking for hints?  check out the examples directory
	# example sketches can be uploaded to your arduino with
	# rake make:upload sketch=examples/hello_world
	# just replace hello_world with other examples

	# hello world (uncomment to run)

	output_pin 3, :as => "led" #Marked as D3 on the breakout

	serial_begin
	@buffer = int
	@amps = 0
	@char_data = "o"
	def loop
		if serial_available()
			@buffer = serial_read()
			@char_data = @buffer

			serial_println @char_data 
			
		end
		led.analogWrite 2

		# blink led,100

	end

end
