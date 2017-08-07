require 'pg'

require_relative '../../../support/benchmark_runner'
require_relative '../../../support/helpers'

module Benchmark
  module PG
    def pg(label = nil, version: ::PG::VERSION.to_s, time:, disable_gc: true, warmup: 3, &block)
      Benchmark::Runner.run(label, version: version, time: time, disable_gc: disable_gc, warmup: warmup, &block)
    end
  end

  extend Benchmark::PG
end
