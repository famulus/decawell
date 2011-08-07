require 'ruby-units'


p hot_side = '500 tempC'.unit >> 'tempK'
p cool_side = '20 tempC'.unit >> 'tempK'

p temp_difference = hot_side - cool_side

p length = "1 cm".unit >> "m"

p k= 'watt'.unit/('kelvin'.unit * 'meter'.unit)

p stainless_steel = "17".unit * k

p thermal_conduction = stainless_steel * (temp_difference / length) 

p thermal_conduction >> 'kW/(m^2)'

p 
