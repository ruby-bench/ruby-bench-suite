#
# Ruby Benchmark driver
#
require 'net/http'
require 'tempfile'
RAW_URL = 'https://raw.githubusercontent.com/ruby-bench/ruby-bench-suite/master/ruby/benchmarks/bm_'

first = true

begin
  require 'optparse'
rescue LoadError
  if first
    first = false
    $:.unshift File.join(File.dirname(__FILE__), '../lib')
    retry
  else
    raise
  end
end

require 'benchmark'
require 'pp'

class BenchmarkDriver
  def self.benchmark(opt)
    driver = self.new(opt[:execs], opt[:dir], opt)
    begin
      driver.run
    ensure
      driver.show_results
    end
  end

  def output *args
    puts(*args)
    @output and @output.puts(*args)
  end

  def message *args
    output(*args) if @verbose
  end

  def message_print *args
    if @verbose
      print(*args)
      STDOUT.flush
      @output and @output.print(*args)
    end
  end

  def progress_message *args
    unless STDOUT.tty?
      STDERR.print(*args)
      STDERR.flush
    end
  end

  def initialize execs, dir, opt = {}
    @execs = execs.map{|e|
      e.strip!
      next if e.empty?

      if /(.+)::(.+)/ =~ e
        # ex) ruby-a::/path/to/ruby-a
        label = $1.strip
        path = $2
        version = `#{path} -v`.chomp
      else
        path = e
        version = label = `#{path} -v`.chomp
      end
      [path, label, version]
    }.compact

    @dir = dir
    @repeat = opt[:repeat] || 1
    @repeat = 1 if @repeat < 1
    @patterns = opt[:pattern] || []
    @excludes = opt[:exclude] || []
    @verbose = opt[:quiet] ? false : (opt[:verbose] || false)
    @output = opt[:output] ? open(opt[:output], 'w') : nil
    @rawdata_output = opt[:rawdata_output] ? open(opt[:rawdata_output], 'w') : nil
    @loop_wl1 = @loop_wl2 = nil
    @ruby_arg = opt[:ruby_arg] || nil
    @opt = opt

    # [[name, [[r-1-1, r-1-2, ...], [r-2-1, r-2-2, ...]]], ...]
    @results = []
    @memory_results = {}

    if @verbose
      @start_time = Time.now
      message @start_time
      @execs.each_with_index{|(path, label, version), i|
        message "target #{i}: " + (label == version ? "#{label}" : "#{label} (#{version})") + " at \"#{path}\""
      }
    end
  end

  def adjusted_results name, results
    results.first.map(&:to_f).min
  end

  def show_results
    output

    if @verbose
      message '-----------------------------------------------------------'
      message 'raw data:'
      message
      message PP.pp(@results, "", 79)
      message
      message "Elapsed time: #{Time.now - @start_time} (sec)"
    end

    if @rawdata_output
      h = {}
      h[:cpuinfo] = File.read('/proc/cpuinfo') if File.exist?('/proc/cpuinfo')
      h[:executables] = @execs
      h[:results] = @results
      @rawdata_output.puts h.inspect
    end

    output '-----------------------------------------------------------'
    output 'benchmark results:'

    if @verbose and @repeat > 1
      output "minimum results in each #{@repeat} measurements."
    end

    output "Execution time (sec)"
    output "name\t#{@execs.map{|(_, v)| v}.join("\t")}"
    @results.each{|v, result|
      rets = adjusted_results(v, result)

      http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org')
      request = Net::HTTP::Post.new('/benchmark_runs')
      request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])

      initiator_hash = {}
      if(ENV['RUBY_COMMIT_HASH'])
        initiator_hash['commit_hash'] = ENV['RUBY_COMMIT_HASH']
      elsif(ENV['RUBY_VERSION'])
        initiator_hash['ruby_version'] = ENV['RUBY_VERSION']
      end

      request.set_form_data({
        'benchmark_type[category]' => "#{v}_memory",
        'benchmark_type[unit]' => 'kilobytes',
        'benchmark_type[script_url]' => "#{RAW_URL}#{v}.rb",
        "benchmark_run[result][rss_kb]" => rets,
        'benchmark_run[environment]' => @execs.map { |(_,v)| v }.first,
        'repo' => 'ruby',
        'organization' => 'tgxworld'
      }.merge(initiator_hash))

      http.request(request)
      output "Posting memory results to Web UI...."
    }

    if @opt[:output]
      output
      output "Log file: #{@opt[:output]}"
    end
  end

  def files
    flag = {}
    @files = Dir.glob(File.join(@dir, 'bm*.rb')).map{|file|
      next if !@patterns.empty? && /#{@patterns.join('|')}/ !~ File.basename(file)
      next if !@excludes.empty? && /#{@excludes.join('|')}/ =~ File.basename(file)

      case file
      when /bm_(vm[12])_/, /bm_loop_(whileloop2?).rb/
        flag[$1] = true
      end
      file
    }.compact

    if flag['vm1'] && !flag['whileloop']
      @files << File.join(@dir, 'bm_loop_whileloop.rb')
    elsif flag['vm2'] && !flag['whileloop2']
      @files << File.join(@dir, 'bm_loop_whileloop2.rb')
    end

    @files.sort!
    progress_message "total: #{@files.size * @repeat} trial(s) (#{@repeat} trial(s) for #{@files.size} benchmark(s))\n"
    @files
  end

  def run
    files.each_with_index{|file, i|
      @i = i
      r = measure_file(file)

      if /bm_loop_whileloop.rb/ =~ file
        @loop_wl1 = r[1].map{|e| e.min}
      elsif /bm_loop_whileloop2.rb/ =~ file
        @loop_wl2 = r[1].map{|e| e.min}
      end
    }
  end

  def measure_file file
    name = File.basename(file, '.rb').sub(/^bm_/, '')
    prepare_file = File.join(File.dirname(file), "prepare_#{name}.rb")
    load prepare_file if FileTest.exist?(prepare_file)

    result = [name]
    result << @execs.map{|(e, v)|
      (0...@repeat).map{
        message_print "#{v}\t"
        m = measure(e, file)
        output "#{name}: rss_kb=#{m}"
        m
      }
    }
    @results << result
    result
  end

  unless defined?(File::NULL)
    if File.exist?('/dev/null')
      File::NULL = '/dev/null'
    end
  end

  def measure executable, file
    cmd = "#{executable} #{@ruby_arg} #{file}"

    begin
      if !(file.match(/so_nsieve_bits/))
        File.copy_stream(file, "#{file}.temp")
        temp_file_read = File.open("#{file}.temp", 'r').read

        if temp_file_read.match(/__END__/)
          begin
            temp = Tempfile.new("extract")
            File.open(file, 'r').each do |line|
              if line.match(/__END__/)
                temp << "mem = `ps -o rss= -p \#\{$$\}`.to_i\nputs \"mem_result:\#\{mem\}\"\n__END__\n"
              else
                temp << line
              end
            end
          ensure
            temp.close
          end
          File.copy_stream(temp, file)
        else
          File.open(file, 'a') do |f|
            f << "mem = `ps -o rss= -p \#\{$$\}`.to_i\n"
            f << "puts \"mem_result:\#\{mem\}\""
          end
        end
      end

      memory = `#{cmd}`
    ensure
      if !(file.match(/so_nsieve_bits/))
        File.copy_stream("#{file}.temp", file)
        File.delete("#{file}.temp")
      end
    end

    if $? != 0
      output "\`#{cmd}\' exited with abnormal status (#{$?})"
      0
    else
      memory.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') =~ /mem_result:(.+)\Z/
      $1.to_f
    end
  end
end

if __FILE__ == $0
  opt = {
    :execs => [],
    :dir => File.dirname(__FILE__),
    :repeat => 1,
    :output => "bmlog-#{Time.now.strftime('%Y%m%d-%H%M%S')}.#{$$}",
    :raw_output => nil
  }

  parser = OptionParser.new{|o|
    o.on('-e', '--executables [EXECS]',
      "Specify benchmark one or more targets (e1::path1; e2::path2; e3::path3;...)"){|e|
       e.split(/;/).each{|path|
         opt[:execs] << path
       }
    }
    o.on('-d', '--directory [DIRECTORY]', "Benchmark suites directory"){|d|
      opt[:dir] = d
    }
    o.on('-p', '--pattern <PATTERN1,PATTERN2,PATTERN3>', "Benchmark name pattern"){|p|
      opt[:pattern] = p.split(',')
    }
    o.on('-x', '--exclude <PATTERN1,PATTERN2,PATTERN3>', "Benchmark exclude pattern"){|e|
      opt[:exclude] = e.split(',')
    }
    o.on('-r', '--repeat-count [NUM]', "Repeat count"){|n|
      opt[:repeat] = n.to_i
    }
    o.on('-o', '--output-file [FILE]', "Output file"){|f|
      opt[:output] = f
    }
    o.on('--ruby-arg [ARG]', "Optional argument for ruby"){|a|
      opt[:ruby_arg] = a
    }
    o.on('--rawdata-output [FILE]', 'output rawdata'){|r|
      opt[:rawdata_output] = r
    }
    o.on('-v', '--verbose'){|v|
      opt[:verbose] = v
    }
    o.on('-q', '--quiet', "Run without notify information except result table."){|q|
      opt[:quiet] = q
      opt[:verbose] = false
    }
  }

  parser.parse!(ARGV)
  BenchmarkDriver.benchmark(opt)
end
