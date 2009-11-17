class Hornet
  def self.convert_voltage(voltage)
    pressure_in_torr = 10**(voltage - 10)
    pressure_in_millitorr = pressure_in_torr*1000
  end
end