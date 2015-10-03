require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :standard_library_tests do
  system("bin/blueprint spec/*-tests.blu") || exit(1)
end

task default: [:spec, :standard_library_tests]
