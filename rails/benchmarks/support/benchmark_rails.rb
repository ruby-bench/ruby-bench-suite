module Benchmark
  module Rails
    def rails(n=1000, label=nil, disable_gc: true, warmup: 3)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      if disable_gc
        GC.disable
      else
        GC.enable
      end

      warmup_iter = 0
      while warmup_iter < warmup
        yield
        warmup_iter += 1
      end

      # warmed up!

      timings = []
      iters = 0
      while iters < n
        before = Time.now
        yield
        after = Time.now

        iters += 1

        timings << (after - before)
      end

      {
        label: label,
        version: ::Rails.version.to_s,
        timing: Helpers.mean(timings).round(5)
      }
    end

    module Helpers
      def mean(samples)
        sum = samples.inject(0) { |acc, i| acc + i }
        sum / samples.size
      end

      module_function :mean
    end
  end

  extend Benchmark::Rails
end
