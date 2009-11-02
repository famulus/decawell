# $Id: acquireNScans.rb 89 2008-04-08 20:09:05Z bikenomad $
#
# acquireNScans.rb: sample program to do multi-channel multi-sample
# analog input
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
chan = "Dev1/ai0:7"	# all 8 single-ended channels
# terminalConfig = Daqmxbase::VAL_CFG_DEFAULT # differential
terminalConfig = Daqmxbase::VAL_RSE # single-ended
min = 0.0
max = 5.0
units = Daqmxbase::VAL_VOLTS

# Timing parameters
source = "OnboardClock"
sampleRate = 10.0
activeEdge = Daqmxbase::VAL_RISING
sampleMode = Daqmxbase::VAL_FINITE_SAMPS
samplesPerChan = 10

# Data read parameters
numSamplesPerChan = Daqmxbase::VAL_CFG_DEFAULT # will wait and then acquire
# numSamplesPerChan = 100
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL # or Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
bufferSize = 80

begin
  task = Daqmxbase::Task.new()
  task.create_aivoltage_chan(chan, terminalConfig, min, max, units) 
  task.cfg_samp_clk_timing(source, sampleRate, activeEdge, sampleMode, samplesPerChan)
  task.start()

  startTime = Time.now
  (data, samplesPerChanRead) = task.read_analog_f64(numSamplesPerChan, timeout, fillMode, bufferSize)
  endTime = Time.now
rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
 p data
 $stdout.puts "read #{samplesPerChanRead}, total time: #{endTime - startTime}, rate: #{samplesPerChanRead/(endTime-startTime)}"
end
