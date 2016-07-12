require_relative 'support/benchmark_bundler.rb'
require 'bundler/cli'

noop_gem = Pathname(__FILE__).expand_path + '../gems/noop-gem'

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write('Gemfile', <<-GEMFILE)
      source 'https://rubygems.org'
      gem 'rails'
      gem 'noop-gem', path: '#{noop_gem}'
    GEMFILE

    # TODO: This caches on first run and all subsequent runs will use cache defeating purpose.
    # Need to clear caches in between runs.
    Benchmark.do_benchmark('bundle lock initial') do
      system("bundle lock")
    end
  end
end
