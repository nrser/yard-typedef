# encoding: UTF-8
# frozen_string_literal: true

##############################################################################
# 
# This file is special - it should not have any dependencies outside the 
# stdlib. It should be loadable without dependencies or paths or bundler
# or anything in place.
# 
# This makes it easy for things that are not at all connected to this package
# or it's environment or whatever to load it up and get some basic info about
# what's going on.
# 
##############################################################################

# Requirements (Stdlib Only!)
# =======================================================================

require 'pathname'
require 'singleton'


# Namespace
# =======================================================================

module  YARD
module  Typedef


# Definitions
# =======================================================================

# Absolute, expanded path to the gem's root directory.
# 
# @return [Pathname]
# 
ROOT = Pathname.new( __dir__ ).join( '..', '..', '..' ).expand_path


# String version read from `//VERSION` and used in the gemspec.
# 
# @return [String]
# 
VERSION = (ROOT + 'VERSION').read.chomp


# The gem name, read from the `//NAME` file, and used in the gemspec.
# 
# @return [String]
# 
NAME = (ROOT + 'NAME').read.chomp


def self.repo?
  ROOT.join( 'dev' ).directory?
end

# {Singleton} extension of {Gem::Version} that loads {VERSION} and
# provides some convenient methods.
# 
class Version < Gem::Version
  include ::Singleton

  # Private method to instantiate the {.instance} using the {VERSION}
  # {String}.
  # 
  # @return [Version]
  # 
  def self.new
    super VERSION
  end

  # We need to mark {.new} as private to dissuade construction of additional
  # instances.
  private_class_method :new

  # Proxies to the {.instance}'s {#dev?}.
  # 
  # @return (see #dev?)
  # 
  def self.dev?
    instance.dev?
  end

  # Tests if the package's version is a development pre-release.
  # 
  # @return [Boolean]
  #   `true` if this is a development pre-release.
  # 
  def dev?
    segments[3] == 'dev'
  end
  
end # module Version


# /Namespace
# =======================================================================

end # module Typedef
end # module YARD
