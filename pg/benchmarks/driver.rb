require 'bundler/setup'
require 'optparse'
require_relative 'pg_suite_runner'

options = {
  pattern: []
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby driver.rb [options]'

  opts.on('-p', '--pattern <PATTERN1,PATTERN2,PATTERN3>', 'Benchmark name pattern') do |value|
    options[:pattern] = value.split(',')
  end
end.parse!(ARGV)

PGSuiteRunner.run(options)
