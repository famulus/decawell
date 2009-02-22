require 'geometry'
include Geometry
require 'facets'
require 'ruby-units'
# require 'winder'

class Unit < Numeric
  @@USER_DEFINITIONS =
    {'<eV>'=>[%w{eV electron_volt electronvolt},  1.60217653*(10.0**-19), :energy, %w{J} ]}
  Unit.setup
end

mm = Unit("mm")
amp = Unit("amp")
ohm = Unit("ohm")

ic = Unit("100 ampere") # the critical current of the superconducting cable
eo = Unit("1 electronvolt")
torus_radius = 34.62 * Unit("mm")
torus_midplane_radius = 79.4172368111867 * Unit("mm")

puts torus_circumference = torus_radius *2* Math::PI

ybco_length = Unit("13 meters") >> Unit("cm")

puts turns = ((ybco_length >> Unit("mm"))/torus_circumference/12).floor


ybco_width = Unit("4 mm") >> Unit("cm")

puts ybco_area = (torus_circumference>>Unit("cm")) * ybco_width

puts engineering_current_density =  Unit("21 kA/cm^2") >> Unit("ampere/cm**2")



# Ampère's force law calculations  http://en.wikipedia.org/wiki/Ampère%27s_force_law
puts "magnetic_constant"
puts magnetic_constant = (4*Math::PI * (10.0**-7)) * Unit("newton/ampere**2")
puts magnetic_force_constant = magnetic_constant / (2*Math::PI)
puts seperation_of_wires = (torus_midplane_radius) >> Unit("m") # in m
puts coil_force_per_meter = magnetic_force_constant * ((ic**2)/seperation_of_wires)
puts coil_force = coil_force_per_meter * ((torus_circumference*turns) >> Unit('m'))
puts  ((coil_force_per_meter * ((torus_circumference*turns) >> Unit('m')))/9.8).scalar*1000 # grams of force

u = 2*Math::PI * (10.0**-7) * ((Unit("tesla") * Unit("m"))/Unit("ampere"))
puts b_field =  u*(ic*turns)/(torus_radius >> Unit("meter"))
puts b_field >> Unit('G')
puts gwb = (((b_field >> Unit('G')) * (torus_midplane_radius >> Unit('cm')))**2) / 110*eo




# bb=2*Math.PI*Math.pow(10,-7)*ii/rr;



# Gwb  = (BR)^2/110Eo, where B is the magnetic field strength (in G) on-axis of  the main faces, 
# R is the radius of the device (in cm) from its center to the midplane of the field coils,
#  and Eo is the depth of the electric potential well (in eV) resulting from the injection of the energetic electrons that drive the device.  
# Typically the well depth is about 0.7-0.9 of the electron injection energy (Ei), 
# depending on the exact geometry of the device and of the injection system.  
# In WB-6 well depth was about 0.8 of injection energy.
