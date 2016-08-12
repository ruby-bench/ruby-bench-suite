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

    system("bundle lock")

    Benchmark.do_benchmark('bundle lock') do
      system("bundle lock")
    end
  end
end
