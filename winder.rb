		# Kernel::require "serialport"

class Coil
require 'facets'
	attr_accessor :grid
	attr_accessor :current_position
	attr_accessor :current_wind
	attr_accessor :truth_array
	


	def wrap_radius_for_row(row = 0)			
		@torus_ring_radius + (@coil_diameter/2) - (row+1)*@coil_wire_diameter			
	end

	def wrap_circumfrence_for_row(row = 0)
		wrap_radius_for_row(row)*2*Math::PI
	end

	def wraps
		self.grid.inject(0){|sum,n| sum+ n.select{|o|o}.size } 
	end

	def coil_length
		length = 0
		self.grid.each_with_index	do |row,index|
			length = length +(row.select{|o|o}.size * wrap_circumfrence_for_row(index))		
		end				
		length
	end

	def find_start
		@grid.each_with_index do |row,rindex|
			row.each_with_index do |cell,cindex|
				# puts "#{[@grid.length-rindex,@grid.length-cindex]}"
				return [@grid.length-rindex,@grid.length-cindex] if cell
			end
		end
	end
	
	def truth_array 
		@truth_array = []
		@grid.each_with_index do |row,rindex|
			row.each_with_index do |cell,cindex|
				if cell #TODO: this has an off by one error
					(@truth_array << [cindex,@grid.length-rindex-1]) if rindex.even?
					(@truth_array << [@grid.length-cindex-1,@grid.length-rindex-1]) if rindex.odd?
				end
			end
		end
		@truth_array
	end
	


	def fill_in_corners
		@grid.each_with_index do |row,r_index|
			row.each_with_index do |cell,c_index|
				break unless cell
				@grid[r_index][c_index] = false					
			end
		end
		@grid.reverse.each_with_index do |row,r_index|
			row.reverse.each_with_index do |cell,c_index|
				break unless cell
				@grid[@grid.size-r_index-1][@grid.size - c_index-1] = false					
			end
		end
	end

	def wind
		#params for serial port
		port_str = "/dev/tty.usbserial-A6006kHu"  #may be different for you
		baud_rate = 9600
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE
		@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
		
		@sp.putc '1' #turn the motors on
		sleep 1 # seconds
		m = Motor.new
		m.name = 'winder'
		m.serial_port = @sp
		m.step_key = 2
		m.direction = 3
		m.direction 

		wg = Motor.new
		wg.name = 'wire_guide'
		wg.serial_port = @sp
		wg.step_key = 5
		wg.direction = 6
		distance =0


		truth_array.each_with_index do |cell,index|
			@current_wind = @current_wind +1
			distance = (cell[0] - truth_array[index-1][0]).abs unless index == 0

			puts "step:#{distance*10}"
			puts "direction" if cell[1] != truth_array[index-1][1] unless index == 0
			m.step(400)
			wg.step(distance*10) if distance > 0
			wg.direction if cell[1] != truth_array[index-1][1] unless index == 0

			# sleep 1

		end
		@sp.putc '0' # turn off the motors
		@sp.close

	end


	def initialize(coil_diameter,coil_wire_diameter,torus_ring_radius)
		#set instance variables
		@coil_diameter = coil_diameter
		@coil_wire_diameter = coil_wire_diameter
		@torus_ring_radius =torus_ring_radius

		diameter = (coil_diameter /coil_wire_diameter).round
		radius = (diameter/2).to_i			
		@current_wind = 0
		@direction = false
		x0 = radius
		y0 = radius
		@grid = (0..(diameter)).to_a.map{|a|(0..(diameter)).to_a.map{|b| true}} #make a 2D matrix of zeros the same diameter as circle all set to false

		f = 1 - radius
		ddF_x = 1
		ddF_y = -2 * radius
		x = 0
		y = radius

		@grid[x0][y0 + radius]   =false
		@grid[x0][ y0 - radius]  =false
		@grid[x0 + radius][ y0]  =false
		@grid[x0 - radius][ y0]  =false

		while(x < y) do          
			if(f >= 0)             
				y -=1                
				ddF_y += 2           
				f += ddF_y           
			end                    
			x +=1                  
			ddF_x += 2             
			f += ddF_x             
			@grid[x0 + x][ y0 + y] =false
			@grid[x0 - x][ y0 + y] =false
			@grid[x0 + x][ y0 - y] =false
			@grid[x0 - x][ y0 - y] =false
			@grid[x0 + y][ y0 + x] =false
			@grid[x0 - y][ y0 + x] =false
			@grid[x0 + y][ y0 - x] =false
			@grid[x0 - y][ y0 - x] =false
		end 
		fill_in_corners
		@current_position = find_start                  
		                 

		return self
	end
end






class Motor
	attr_accessor :serial_port,:name,:step_key, :direction,:off_key,:on_key,:position,:current_direction

	def initialize
		@current_direction = true
		@position = 0
	end


	def step(times = 1)
		times.times do |step|
			@serial_port.putc @step_key.to_s
			# puts "#{ @step_key}"

			sleep 0.005
			if @current_direction
				@position = @position +1
			else
				@position = @position -1
			end

		end
	end

	def direction
		@current_direction = !@current_direction
		@serial_port.putc @direction.to_s

	end
	def direction=(pin)
		@direction = pin
	end


end

