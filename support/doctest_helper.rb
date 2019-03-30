require 'pry'
require 'pathname'
require 'set'

ROOT = Pathname.new File.expand_path( '..', __dir__ )
LIB_PATH = ROOT.join 'lib'

$yard_doctest_required_filepaths = Set.new

def require_from_filepath filepath
  return if $yard_doctest_required_filepaths.include?( filepath )
  path = /\A(.*)\:\d+\z/.match( filepath )[ 1 ]
  lib_rel = Pathname.new( path ).relative_path_from( LIB_PATH ).to_s
  req_path = lib_rel.sub /\.rb\z/, ''
  require req_path
  $yard_doctest_required_filepaths << filepath
rescue
  log.warn "Unable to require from filepath #{ filepath.inspect }"
end

YARD::Doctest.configure do |doctest|
  doctest.before do |example|
    # this is called before each example and
    # evaluated in the same context as example
    # (i.e. has access to the same instance variables)
    
    require_from_filepath example.filepath
  end

  doctest.after do
    # same as `before`, but runs after each example
  end

  doctest.after_run do
    # runs after all the examples and
    # has different context
    # (i.e. no access to instance variables)
  end
end
