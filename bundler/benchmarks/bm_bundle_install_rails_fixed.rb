require_relative 'support/benchmark_bundler.rb'
require 'bundler/cli'

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write('Gemfile', <<-GEMFILE)
      source 'https://rubygems.org'
      gem 'rails', '5.0.0'
      gem 'nokogiri', '1.6.7.2'
    GEMFILE

    system("bundle package --quiet")
    system("bundle install --quiet")

    Benchmark.do_benchmark('bundle install rails fixed', time: 60) do
      system("bundle install --quiet")
    end
  end
end
