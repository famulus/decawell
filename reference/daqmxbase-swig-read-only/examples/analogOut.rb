# $Id: analogOut.rb 89 2008-04-08 20:09:05Z bikenomad $
#
# analogOut.rb: sample program to do multiple-channel analog output
#
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
#

$suppressStderr = false
BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
chan = "Dev1/ao0"
terminalConfig = Daqmxbase::VAL_CFG_DEFAULT
min = 0.0
max = 5.0
units = Daqmxbase::VAL_VOLTS

# Data write parameters
data = [ 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 4.0, 3.0, 2.0, 1.0 ] * 1000
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL # or Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
samplesPerChan = data.size
timeout = (data.size / 150.0) * 2

begin
  task = Daqmxbase::Task.new
  task.create_aovoltage_chan(chan, min, max, units) 
  task.start()

  while true
    startTime = Time.now
    (samplesPerChanRead) = task.write_analog_f64(samplesPerChan,
                0, timeout, fillMode, data)
    endTime = Time.now
          rate = samplesPerChanRead/(endTime-startTime)
          $stdout.puts "write #{samplesPerChanRead}, total time: #{endTime - startTime}, rate: #{rate}"
  end

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
  $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
