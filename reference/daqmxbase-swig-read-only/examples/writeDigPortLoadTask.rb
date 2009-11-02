# $Id: writeDigPortLoadTask.rb 89 2008-04-08 20:09:05Z bikenomad $
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
$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'

# Task parameters
task = nil

# You can set up the port voltages
# using the NI-DAQmx Base Task Configuration utility
# 3.3v is push/pull
# 5V is open drain
taskName = "dio write port"

# Channel parameters
chan = "Dev1/port0" # all 8 bits in this port
# chan = "Dev1/port0:1" # all 12 bits in both ports

# Data read parameters
timeout = 10.0
# fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
fillMode = Daqmxbase::VAL_GROUP_BY_SCAN_NUMBER
autoStart = 0
outData = (0..31).to_a.collect { |n| 2**n }
numSampsPerChan = outData.size
p [ outData, numSampsPerChan ]

begin
  task = Daqmxbase::Task.new(taskName)
  task.create_dochan(chan)
  task.start()

  while true do
    task.write_digital_scalar_u32(autoStart, timeout, 0x01)
    nWritten = task.write_digital_u8(numSampsPerChan, autoStart, timeout, fillMode, outData)
#    p [ numSampsPerChan, nWritten  ]
    nWritten = task.write_digital_u32(numSampsPerChan, autoStart, timeout, fillMode, outData)
#    p [ numSampsPerChan, nWritten  ]
  end

  puts("")

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
