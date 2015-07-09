require 'bundler'
require 'benchmark/ips'
require 'json'
require 'tempfile'

ENV['BUNDLE_GEMFILE'] = 'Gemfile'

rubygems = Bundler.rubygems
def rubygems.validate(spec); end

# Bundler.ui = Bundler::UI::Shell.new

module Benchmark
  module Bundler
    module Resolver
      def resolve_definition(label, gemfile, lockfile: nil, unlock: true, git_gems: {})
        builder = ::Bundler::Dsl.new
        builder.instance_eval(&gemfile)
        if lockfile
          tmp_lockfile = Tempfile.new("#{label}_lockfile")
          tmp_lockfile.write lockfile
          lockfile = tmp_lockfile.path
        end
        unlock = { gems: unlock } if Array === unlock
        definition = builder.to_definition(lockfile, unlock)

        definition.send(:sources).git_sources.each do |s|
          if specs = git_gems[s.to_s]
            s.define_singleton_method(:specs) do
              @specs ||= begin
                ::Bundler::Index.build do |idx|
                  idx.use Array(specs)
                end
              end
            end
          end
        end

        definition.resolve_remotely!

        block = proc do
          definition.instance_variable_set(:@specs, nil)
          definition.instance_variable_set(:@resolve, nil)
          definition.specs
        end

        do_benchmark(label, &block)
      end

      def do_benchmark(label, time: 20, warmup: 7, &block)
        report = Benchmark.ips(time, warmup, true) do |bm|
          bm.report(label, &block)
        end

        entry = report.entries.first
        output = JSON.pretty_generate({
          label: label,
          version: ::Bundler::VERSION,
          iterations_per_second: entry.ips,
          iterations_per_second_standard_deviation: entry.stddev_percentage,
          total_allocated_objects_per_iteration: get_total_allocated_objects(&block),
        })

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
  end

  extend Bundler::Resolver
end
