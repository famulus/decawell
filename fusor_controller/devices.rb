class Hornet
	def self.convert_voltage(voltage)
		pressure_in_torr = 10**(voltage - 10)
		pressure_in_millitorr = pressure_in_torr*1000
	end
end

class Glassman
	def self.current(voltage)
		# the Glassman goes from 0 to 10 milliamps  represented by 0 to 10 volts
		voltage
	end

	def self.voltage(voltage)
		# the Glassman goes from 0 to 30,000 volts represented by 0 to 10 volts
		voltage*3000
	end
end

class Stec
	def self.convert_voltage(voltage)
		# the Stec goes from 0 to 20 sccm represented by 0 to 5 volts
		voltage*4
	end
end