Kernel::require "serialport"
#params for serial port
port_str = "/dev/tty.usbserial-A6006kHu"  #may be different for you
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
input = ""
# while input != "q"
# 	puts "Light a light:"
# 	input = gets.chomp
# 	sp.putc input.to_s
# end




class Motor
	attr_accessor :serial_port,:name,:step_key, :direction,:off_key,:on_key
	def step(times = 1)
		times.times do |step|
			@serial_port.putc @step_key.to_s
			puts "#{ @step_key}"
			sleep 0.005
		end
	end

	def direction
		@serial_port.putc @direction.to_s
	end
	def direction=(pin)
		@direction = pin
	end


end

sp.putc '1' #turn the motors on
sleep 0.5 # seconds


# 1000 step = 100 mm 


m = Motor.new
m.name = 'winder'
m.serial_port = sp
m.step_key = 2
m.direction = 3




wg = Motor.new
wg.name = 'wire_guide'
wg.serial_port = sp
wg.step_key = 5
wg.direction = 6

400.times do |rev|
	m.step(10)

	wg.step(2)


end


sp.putc '0'


sp.close
