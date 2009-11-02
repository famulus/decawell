# $Id: readDigPort.rb 89 2008-04-08 20:09:05Z bikenomad $
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

# Channel parameters
chan = "Dev1/port0"	# all 8 bits in this port

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
bufferSize = 100
numSampsPerChan = bufferSize

begin
  task = Daqmxbase::Task.new(nil)
  task.create_dichan(chan);
  task.start()

  data = task.read_digital_scalar_u32(timeout)
  printf("read_digital_scalar_u32: 0x%x\n", data)

  (data, sampsPerChanRead) = task.read_digital_u32(numSampsPerChan, timeout, fillMode, bufferSize)
  printf("read_digital_u32 read %d samps/chan: ", sampsPerChanRead)
  data.each { |d| printf(" 0x%x", d) }

  (data, sampsPerChanRead) = task.read_digital_u8(numSampsPerChan, timeout, fillMode, bufferSize)
  printf("\nread_digital_u8 read %d samps/chan: ", sampsPerChanRead)
  data.each { |d| printf(" 0x%x", d) }
  puts("")

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end
