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
	attr_accessor :serial_port,:name,:step_key, :forward_key,:backward_key,:off_key,:on_key
	def step(times = 1)
		times.times do |step|
			@serial_port.putc @step_key.to_s

			puts "#{ @step_key}"
		end
	end
end

sp.putc '1'
			sleep 0.5 # seconds

m = Motor.new
m.name = 'winder'
m.serial_port = sp
m.step_key = 2
m.forward_key = 3
m.backward_key = 4

m.step(400)
sp.putc '0'


sp.close
