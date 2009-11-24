
class Array
	def average
		inject(0.0) { |sum, e| sum + e } / length
	end
end

class Float
	def round_to(x)
		(self * 10**x).round.to_f / 10**x
	end
end

class Hornet
	def self.interpret_voltage(voltage)
		pressure_in_torr = 10**(voltage - 10)
		pressure_in_millitorr = pressure_in_torr*1000
	end
	def self.title
	 "Pressure in millitorr"
	end
	
end

class GlassmanCurrent
	def self.interpret_voltage(voltage)
		# the Glassman goes from 0 to 10 milliamps  represented by 0 to 10 volts
		voltage #- (offset = 1.39)
	end
	def self.title
	 "Current in milliamps"
	end
	
end

class GlassmanVoltage
	def self.interpret_voltage(voltage)
		# the Glassman goes from 0 to 30,000 volts represented by 0 to 10 volts
    voltage*3.2 + (offset = 3.93) # I added these correction factors to get a better match with voltage measurement from the voltage divider. These may prove inaccurate under load.
	end
	
	def self.title
	 "Voltage in Kilovolts"
	end	
end


class VoltageDivider
  def self.interpret_voltage(voltage)
    voltage*3.0
  end
  def self.title
	 "Voltage in Kilovolts"
	end	
	
end



class Stec
	def self.interpret_voltage(voltage)
		# the Stec goes from 0 to 20 sccm represented by 0 to 5 volts
		voltage*4
	end
	
	def self.title
	 "Mass Flow in SCCM"
	end
	
end


CHANNEL_BANK = [Hornet,VoltageDivider,GlassmanCurrent,Stec]
