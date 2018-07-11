#!/usr/bin/env ruby

require 'digest'
require 'optparse'
require 'shellwords'

opt = { pattern: [], runner: 'seconds' }

OptionParser.new{|o|
  o.on('-r', '--runner RUNNER', String, "Runner (default: seconds)"){|r|
    opt[:runner] = r
  }
  o.on('-e', '--executables [EXEC]', "Specify benchmark target (e1::path1)"){|e|
    opt[:exec] = e # discard...
  }
  o.on('-p', '--pattern <PATTERN1,PATTERN2,PATTERN3>', "Benchmark name pattern"){|p|
    opt[:pattern] = p.split(',')
  }
  o.on('--with-jit', "Run benchmarks once with JIT enabled and once without"){
    opt[:jit] = true
  }
  o.on('--repeat-count [NUM]', "Repeat count"){|n|
    opt[:repeat] = n.to_i
  }
  o.on('-o', '--output-file [FILE]', "Output file"){|f|
    opt[:output] = f # discard...
  }
}.parse!(ARGV)

filter = opt.fetch(:pattern).map { |p| ['--filter', p] }.flatten

benchmark_dir = File.expand_path('./benchmark', __dir__)
benchmarks = Dir.glob("#{benchmark_dir}/*.rb") + Dir.glob("#{benchmark_dir}/*.yml")

benchmarks.sort.each do |benchmark|
  if opt[:runner] == 'rsskb'
    name = 'rss_kb'
  else
    name = File.basename(benchmark).sub(/\.[^.]+\z/, '')
  end
  execs = ['-e', "#{name}::#{RbConfig.ruby.shellescape}"]
  if opt[:jit]
    execs += ['-e', "#{name}_jit::#{RbConfig.ruby.shellescape} --jit"]
  end

  ENV['REPO_NAME'] = 'ruby'
  ENV['ORGANIZATION_NAME'] = 'ruby'
  ENV['BENCHMARK_TYPE_DIGEST'] = Digest::SHA2.file("#{File.dirname(__FILE__)}/benchmark/#{File.basename(benchmark)}").hexdigest
  ENV['BENCHMARK_TYPE_SCRIPT_URL'] = "https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmark/#{File.basename(benchmark)}"
  ENV['RUBY_ENVIRONMENT'] = 'true'

  command = [
    'benchmark-driver', benchmark, *execs, *filter,
    '--runner', opt[:runner], '--output', 'rubybench',
    '--repeat-count', opt[:repeat].to_s,
    '--repeat-result', 'best',
    '--timeout', '60',
  ]

  puts "+ #{command.shelljoin}"
  unless system(command.shelljoin)
    abort "Failed to execute: #{command.shelljoin}"
  end
end
