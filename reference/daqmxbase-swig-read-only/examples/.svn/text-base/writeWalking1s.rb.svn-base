# $Id$
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
chan = "Dev1/port0/line0:3" # all 8 bits in this port

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
autoStart = 0
outData = (0..7).to_a.collect { |n| 2**n }
numSampsPerChan = 1

begin
  task = Daqmxbase::Task.new()
  task.create_dochan(chan);
  task.start()

  4.times {
  outData.each { |n| 
    written = task.write_digital_u32(numSampsPerChan, autoStart, timeout, fillMode, n)
    printf "%#x ", n
    p written if written != numSampsPerChan
  }
  }

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
end

# vim: ft=ruby ts=2 sw=2 et
