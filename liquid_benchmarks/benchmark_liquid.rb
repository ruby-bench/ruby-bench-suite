require 'benchmark/ips'
require 'json'

require_relative '../support/benchmark_runner'

module Benchmark
  module Liquid
    def liquid(label=nil, version: ::Liquid::VERSION.to_s, time: 10, disable_gc: false, warmup: 5, &block)
      Benchmark::Runner.run(label, version: version, time: time, disable_gc: disable_gc, warmup: warmup, &block)
    end
  end

  extend Benchmark::Liquid
end
