require 'digest'
require_relative 'optcarrot/lib/optcarrot'

ENV['BENCHMARK_TYPE_SCRIPT_URL'] = 'https://raw.githubusercontent.com/mame/optcarrot/master/lib/optcarrot/nes.rb'
ENV['BENCHMARK_TYPE_DIGEST']     = Digest::SHA2.hexdigest(Optcarrot::VERSION)
ENV['REPO_NAME']                 = 'ruby'
ENV['ORGANIZATION_NAME']         = 'ruby'

ruby_options = ['-e', "default::#{RbConfig.ruby}"]
if Gem::Version.new(`ruby -e "puts RUBY_VERSION"`.chomp) >= Gem::Version.new('2.6.0')
  ruby_options.concat(['-e', "default_jit::#{RbConfig.ruby},--jit"])
end

benchmark_yml = File.expand_path('./optcarrot/benchmark.yml', __dir__)
exec 'benchmark-driver', benchmark_yml, '-o', 'rubybench', *ruby_options, \
  '--repeat-count', '3', '--repeat-result', 'average'
