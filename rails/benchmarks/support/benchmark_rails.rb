require 'rails'
require 'benchmark/ips'
require 'json'

require_relative 'helpers.rb'

module Benchmark
  class Rails
    def initialize(label, time:, disable_gc: true, warmup: 3)
      @label = label
      @time = time
      @disable_gc = disable_gc
      @warmup = warmup
      @entries = {}
      yield(self)
      print
    end

    def report(result_label, &block)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      if @disable_gc
        GC.disable
      else
        GC.enable
      end

      report = Benchmark.ips(@time, @warmup, true) do |x|
        x.report { yield }
      end

      @entries[result_label] = [report.entries.first, get_total_allocated_objects(&block)]
    end

    def print
      output = {
        label: @label,
        version: ::Rails.version.to_s,
        results: {}
      }

      @entries.each do |result_label, entry|
        output[:results][result_label] = {
          iterations_per_second: entry[0].ips,
          iterations_per_second_standard_deviation: entry[0].stddev_percentage,
          total_allocated_objects_per_iteration: entry[1]
        }
      end

      puts output.to_json
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
end
