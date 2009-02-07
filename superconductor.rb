require 'geometry'
include Geometry
require 'facets'
require 'ruby-units'
# require 'winder'

mm = Unit("mm")
amp = Unit("amp")
ohm = Unit("ohm")


torus_radius = 34.62 * Unit("mm")

puts torus_circumference = torus_radius *2* Math::PI

ybco_length = Unit("13 meters") >> Unit("cm")

puts turns = ((ybco_length >> Unit("mm"))/torus_circumference/12).floor


ybco_width = Unit("4 mm") >> Unit("cm")

puts ybco_area = (torus_circumference>>Unit("cm")) * ybco_width

puts engineering_current_density =  Unit("21 kA/cm^2") >> Unit("ampere/cm**2")

puts current_density = ybco_area * engineering_current_density

torus_midplane_radius = 79.4172368111867 
# Ampère's force law calculations  http://en.wikipedia.org/wiki/Ampère%27s_force_law
puts "magnetic_constant"
puts magnetic_constant = (4*Math::PI * (10.0**-7)) * Unit("newton/ampere**2")
puts magnetic_force_constant = magnetic_constant / (2*Math::PI)
puts seperation_of_wires = (torus_midplane_radius*mm) >> Unit("m") # in m
puts coil_force_per_meter = magnetic_force_constant * ((current_density**2)/seperation_of_wires)
puts coil_force = coil_force_per_meter * (torus_circumference >> Unit('m'))
puts  ((coil_force_per_meter * (torus_circumference >> Unit('m')))/9.8).scalar # Kg of force
puts  ((coil_force_per_meter * (torus_circumference >> Unit('m')))/9.8).scalar / 816 # number of honda civics of force
puts (turns )*current_density