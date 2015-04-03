require 'benchmark/ips'
require 'json'

module Benchmark
  module Rails
    def rails(label=nil, time:, disable_gc: true, warmup: 3, &block)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      if disable_gc
        GC.disable
      else
        GC.enable
      end

      report = Benchmark.ips(time, warmup, true) do |x|
        x.report(label) { yield }
      end

      entry = report.entries.first

      output = {
        label: label,
        version: ::Rails.version.to_s,
        iterations_per_second: entry.ips,
        iterations_per_second_standard_deviation: entry.stddev_percentage,
        total_allocated_objects_per_iteration: get_total_allocated_objects(&block)
      }.to_json

      puts output
    end

    def get_total_allocated_objects
      if block_given?
        key =
          if RUBY_VERSION < '2.2'
            :total_allocated_object
          else
            :total_allocated_objects
          end

        before = GC.stat[key]
        yield
        after = GC.stat[key]
        after - before
      end
    end
  end

  extend Benchmark::Rails
end
