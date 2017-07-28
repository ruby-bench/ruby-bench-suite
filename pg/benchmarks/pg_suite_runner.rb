# PG suite runner

require 'net/http'
require 'json'
require 'pathname'
require 'pg'
require 'digest'

class PGSuiteRunner
  RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/pg/benchmarks/'

  HOST = ENV['POSTGRES_PORT_5432_TCP_ADDR'] || 'localhost'
  PORT = ENV['POSTGRES_PORT_5432_TCP_PORT'] || 5432
  DATABASE_URL = "postgres://postgres@#{HOST}:#{PORT}/rubybench"

  def self.run(options)
    new(options).run
  end

  def initialize(options)
    @pattern = options[:pattern]
  end

  def run
    bm_scripts.each do |bm_script|
      run_benchmark(bm_script) if match_pattern?(bm_script)
    end
  end

  private

  def bm_scripts
    Dir["#{File.expand_path(File.dirname(__FILE__))}/*"].select! { |path| path =~ /bm_.+/ }
  end

  def match_pattern?(bm_script)
    /#{@pattern.join('|')}/ =~ File.basename(bm_script) || @pattern.empty?
  end

  def run_benchmark(bm_script)
    execute("PG_MASTER=1 DATABASE_URL=#{DATABASE_URL} ruby #{bm_script}")
  end

  def execute(command)
    result = JSON.parse(`#{command}`)
    puts "[#{result['label']}] #{result['iterations_per_second']} ips, #{result['total_allocated_objects_per_iteration']} objects"
    result
  end
end
