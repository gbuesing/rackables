Gem::Specification.new do |s|
  s.name    = 'rackables'
  s.version = '0.3.0'
  s.author  = 'Geoff Buesing'
  s.email   = 'gbuesing@gmail.com'
  s.summary = 'A collection of useful Rack middleware'
  s.license = 'MIT'
  s.homepage = 'https://github.com/gbuesing/rackables'

  s.add_dependency 'rack'
  s.add_development_dependency 'rack-test'

  s.files = Dir['lib/rackables.rb', 'lib/rackables/*.rb', 'lib/rackables/more/*.rb']
end