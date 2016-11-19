require 'net/http'
require 'digest'
require_relative 'optcarrot/lib/optcarrot'

ROM = 'Lan_Master.nes'

results = []
checksums = []

3.times do |i|
  output = `ruby #{File.dirname(__FILE__)}/optcarrot/bin/optcarrot --benchmark #{File.dirname(__FILE__)}/optcarrot/examples/#{ROM}`
  fps, checksum = output.split("\n")
  fps = fps[/fps: (.+)/, 1].to_i
  results << fps
  checksum = checksum[/checksum: (.+)/, 1]
  checksums << checksum

  puts "Iteration #{i + 1}..."
  puts "FPS: #{fps}"
  puts "Checksum: #{checksum}"
end

avg_fps = results.inject{ |sum, el| sum + el }.to_f / results.size
checksum = checksums.uniq.first

http = Net::HTTP.new(ENV["API_URL"] || 'rubybench.org', 443)
http.use_ssl = true
request = Net::HTTP::Post.new('/benchmark_runs')
request.basic_auth(ENV["API_NAME"], ENV["API_PASSWORD"])

initiator_hash = {}
if(ENV['RUBY_COMMIT_HASH'])
  initiator_hash['commit_hash'] = ENV['RUBY_COMMIT_HASH']
elsif(ENV['RUBY_VERSION'])
  initiator_hash['version'] = ENV['RUBY_VERSION']
end

request.set_form_data({
  'benchmark_result_type[name]' => 'Number of frames',
  'benchmark_result_type[unit]' => 'fps',
  'benchmark_type[category]' => "Optcarrot #{ROM}",
  'benchmark_type[script_url]' => "https://raw.githubusercontent.com/mame/optcarrot/master/lib/optcarrot/nes.rb",
  'benchmark_type[digest]' => Digest::SHA2.hexdigest(Optcarrot::VERSION),
  "benchmark_run[result][default]" => avg_fps,
  'benchmark_run[environment]' => { "Ruby version" => `ruby -v`, "Checksum" => checksum },
  'repo' => 'ruby',
  'organization' => 'ruby'
}.merge(initiator_hash))

puts http.request(request).body
puts "Posting results to Web UI...."
puts "Average FPS: #{avg_fps}"
puts "Checksum: #{checksum}"


