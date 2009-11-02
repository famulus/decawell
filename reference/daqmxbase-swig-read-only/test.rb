# $Id: test.rb 89 2008-04-08 20:09:05Z bikenomad $
#-----------------------------------------------------------------------
# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#-----------------------------------------------------------------------
require "daqmxbase"

def testOne
  deviceName = "Dev1"
  chan = deviceName + "/ai0:2"
  points_to_read = 3
  timeout = 10.0
  samples_per_chan = 10
  minVal = -1.0
  maxVal = 1.0

  task = Daqmxbase::Task.new
  print "create_aivoltage_chan: "
  p task.create_aivoltage_chan(chan,Daqmxbase::VAL_CFG_DEFAULT,minVal,maxVal,Daqmxbase::VAL_VOLTS)
  print "start: "
  p task.start()
  print "read_analog_f64: " 
  p task.read_analog_f64(Daqmxbase::VAL_AUTO, timeout, Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER, samples_per_chan * points_to_read)
  puts "done"
end

testOne()
