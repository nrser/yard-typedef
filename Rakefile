require "bundler/gem_tasks"


desc %(Run `yard doctest`)
task :doctest do
  # paths = Dir[ './lib/**/*.rb' ].select do |path|
  #   File.open( path, 'r' ).each_line.lazy.take( 32 ).find do |line|
  #     line.start_with? '# doctest: true'
  #   end
  # end
  
  # sh %(yard doctest #{ paths.shelljoin })
  sh %(yard doctest)
end # task :doctest


task :default => [ :doctest ]
