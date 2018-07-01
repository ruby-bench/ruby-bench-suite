
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "benchmark_driver/output/rubybench/version"

Gem::Specification.new do |spec|
  spec.name          = "benchmark_driver-output-rubybench"
  spec.version       = BenchmarkDriver::Output::Rubybench::VERSION
  spec.authors       = ["Takashi Kokubun"]
  spec.email         = ["takashikkbn@gmail.com"]

  spec.summary       = %q{benchmark_driver plugin to output result to RubyBench}
  spec.description   = %q{benchmark_driver plugin to output result to RubyBench}
  spec.homepage      = "https://github.com/ruby-bench/ruby-bench-suite"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "benchmark_driver", ">= 0.12"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
