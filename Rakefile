require 'rake/testtask'

Rake::TestTask.new do |t|
  require 'rubygems'
  require 'rack'

  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :default => :test

