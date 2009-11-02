# $Id: testload.rb 89 2008-04-08 20:09:05Z bikenomad $
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
$stdout.sync=true

def printDerived(klass)
  puts "\n#{klass.name} has parents #{klass.ancestors.inspect}"

  puts "\nNew #{klass.name} methods"
  p klass.methods - klass.class.methods
  puts ""

  puts "\nNew #{klass.name} instance methods"
  p klass.instance_methods - klass.class.instance_methods
  puts ""

  puts "\nNew #{klass.name} constants"
  p klass.constants - klass.class.constants
  puts ""
end

printDerived(Daqmxbase)
printDerived(Daqmxbase::Task)
printDerived(Daqmxbase::Error)
printDerived(Daqmxbase::Warning)
