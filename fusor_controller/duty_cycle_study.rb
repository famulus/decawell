#http://en.wikipedia.org/wiki/Pulse-width_modulation
wavelength = 10.0 #length in seconds for the wavelength
duty_cycle = 0.7 # a float between 0 and 1
time_on = wavelength*duty_cycle
start_time = Time.now()
state = true
while true
	time_now = Time.now()
	(duration = (time_on) ) if state 
	(duration = (wavelength - time_on)) unless state 
	if ((time_now - start_time) > (duration))
		state = !state
		start_time = time_now
	end
	puts state
end