require 'benchmark/ips'
require 'json'

module Benchmark
  module Rails
    def rails(label=nil, time:, disable_gc: true, warmup: 3)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      if disable_gc
        GC.disable
      else
        GC.enable
      end

      report = Benchmark.ips do |x|
        x.config(time: time, warmup: warmup, quiet: true)
        x.report(label) { yield }
      end

      entry = report.entries.first

      output = {
        label: label,
        version: ::Rails.version.to_s,
        ips: entry.ips,
        ips_sd_percentage: entry.stddev_percentage
      }.to_json

      puts output
    end
  end

  extend Benchmark::Rails
end
