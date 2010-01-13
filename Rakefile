require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rackables"
    gemspec.summary = "Bundle of useful Rack middleware"
    gemspec.description = "Bundles Rack middleware: CacheControl, DefaultCharset, PublicExceptionPage, TrailingSlashRedirect"
    gemspec.email = "gbuesing@gmail.com"
    gemspec.homepage = "http://github.com/gbuesing/rackables"
    gemspec.authors = ["Geoff Buesing"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
