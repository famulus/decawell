# Simple collection statistics.
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

module Enumerable
  def sum
    return 0.0 if empty?
    inject(0.0) { |accum,ea| accum + ea }
  end

  def average
    return 0.0 if empty?
    sum / size 
  end

  def rms
    return 0.0 if empty?
    sumsq = inject(0.0) { |accum,ea| accum + ea * ea }
    (sumsq / size) ** 0.5
  end

  def peak_to_peak
    return 0.0 if empty?
    vmax = Float::MIN
    vmin = Float::MAX
    each do |ea|
      vmin = ea if ea < vmin
      vmax = ea if ea > vmax
    end
    vmax - vmin
  end
end

if __FILE__ == $0
  require 'test/unit'

  class AS_TC < Test::Unit::TestCase

    def setup
      @a = (0..100).to_a
      delta = 2.0*Math::PI / @a.size
      @sines = @a.collect { |ea| Math.sin(ea * delta) }
    end

    def test_sum
      assert_equal(@a.sum, 5050)
    end

    def test_average
      assert_equal(@a.average, 50.0)
    end

    def test_rms
      assert_in_delta(57.8792, @a.rms, 0.0001)
      assert_in_delta(0.7071, [0,1].rms, 0.0001)
      assert_in_delta(0.7071, @sines.rms, 0.0001)
    end

    def test_peak_to_peak
      assert_equal(@a.peak_to_peak, 100.0)
      assert_in_delta(2.0, @sines.peak_to_peak, 0.001)
    end

  end
end
