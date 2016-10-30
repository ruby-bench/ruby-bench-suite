require_relative 'support/benchmark_bundler.rb'
require 'bundler/cli'

Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    File.write('Gemfile', <<-GEMFILE)
      source 'https://rubygems.org'
      gem 'rails', '5.0.0.rc1'
      gem 'nokogiri', '1.6.7.0'
    GEMFILE

    system("bundle install --quiet")
    system("bundle outdated --quiet")

    Benchmark.do_benchmark('bundle outdated rails') do
      system("bundle outdated --quiet")
    end
  end
end
