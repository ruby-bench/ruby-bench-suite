# PG suite runner

require 'net/http'
require 'json'
require 'pathname'
require 'pg'
require 'digest'

class PGSuiteRunner
  RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/pg/benchmarks/'

  DATABASE_URL = "postgres://postgres@postgres:5432/rubybench"

  def self.run(options)
    new(options).run
  end

  def initialize(options)
    @pattern = options[:pattern]
  end

  def run
    bm_scripts.each do |bm_script|
      if match_pattern?(bm_script)
        output = run_benchmark(bm_script)
        send_results(output, bm_script)
      end
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
    execute("DATABASE_URL=#{DATABASE_URL} ruby #{bm_script}")
  end

  def execute(command)
    p JSON.parse(`#{command}`)
  end

  def send_results(output, bm_script)
    form_data = default_form_data(output, bm_script)

    send_ips(output, form_data)
    send_objects(output, form_data)
  end

  def default_form_data(output, bm_script)
    {
      'benchmark_type[category]' => output['label'],
      'benchmark_type[script_url]' => "#{RAW_URL}#{Pathname.new(bm_script).basename}",
      'benchmark_type[digest]' => generate_digest(bm_script),
      'benchmark_run[environment]' => `ruby -v`,
      'repo' => 'ruby-pg',
      'organization' => 'ged',
      'commit_hash' => ENV['PG_COMMIT_HASH']
    }
  end

  def send_ips(output, form_data)
    form_data = form_data.merge(
      'benchmark_run[result][iterations_per_second]' => output['iterations_per_second'].round(3),
      'benchmark_result_type[name]' => 'Number of iterations per second',
      'benchmark_result_type[unit]' => 'Iterations per second'
    )

    submit_request(form_data)
  end

  def send_objects(output, form_data)
    form_data = form_data.merge(
      'benchmark_run[result][total_allocated_objects_per_iteration]' => output['total_allocated_objects_per_iteration'],
      'benchmark_result_type[name]' => 'Allocated objects',
      'benchmark_result_type[unit]' => 'Objects'
    )

    submit_request(form_data)
  end

  def submit_request(form_data)
    request = generate_request
    request.set_form_data(form_data)
    endpoint.request(request)
  end

  def generate_request
    request = Net::HTTP::Post.new('/benchmark_runs')
    request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])
    request
  end

  def endpoint
    http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org', 443)
    http.use_ssl = true
    http
  end

  def generate_digest(bm_script)
    Digest::SHA2.hexdigest("#{File.read(bm_script)}#{`ruby -v`}")
  end
end
