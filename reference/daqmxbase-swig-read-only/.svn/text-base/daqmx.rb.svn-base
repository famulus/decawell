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
require 'daqmxbase'

# Dev1/ai0 .. Dev1/ai7 (rse)
# Dev1/ai0 .. Dev1/ai4 (diff)
# Dev1/port0 (8 bits)
# Dev1/port0:1 (12 bits)
# Dev1/port1 (4 bits)
# Dev1/port1/line0:3 (4 bits, same as above)
# Dev1/port0/line0:3 (4 bits)
# Dev1/ctr0

module USB600x
  include Daqmxbase

  class ChannelConfig
  end

  class AnalogInputChannelConfig < ChannelConfig
  end

  class AnalogOutputChannelConfig < ChannelConfig
  end

  class DigitalIOChannelConfig < ChannelConfig
  end

  # event input counting (falling edge only on PI0)
  class CtrInputChannelConfig < ChannelConfig
  end

  class Task < Daqmxbase::Task
    # task states
    Uncommitted = 0 # no channels created
    Committed = 1   # channels created
    Inactive = 2    # not started yet, or finished
    Active = 3      # started

    def initialize(taskName = nil)
      super
      @state = Uncommitted
    end

    def clear
      super
      @state = Uncommitted
    end

    def start
      super
      @state = Active
    end

    def stop
      super
      @state = Inactive
    end

    def done?
      return true if state != Active 
      isDone = self.is_task_done
      @state = Inactive if isDone == 1
      isDone == 1
    end

    attr_reader :state

  end

  class Device
    def initialize(deviceName = "Dev1")
      @deviceName = deviceName
    end

  # DANGER: don't use at beginning of pgms
    def reset
      Daqmxbase::reset_device(@deviceName)
    end

    def serialNumber
      Daqmxbase::get_dev_serial_num(@deviceName)
    end

    attr_reader :deviceName
  end

end
