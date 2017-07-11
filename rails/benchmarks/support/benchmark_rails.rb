require 'rails'

require_relative '../../../support/benchmark_runner'
require_relative '../../../support/helpers'

module Benchmark
  module Rails
    def rails(label = nil, version: ::Rails.version.to_s, time:, disable_gc: true, warmup: 3, &block)
      Benchmark::Runner.run(label, version: version, time: time, disable_gc: disable_gc, warmup: warmup, &block)
    end
  end

  extend Benchmark::Rails
end
