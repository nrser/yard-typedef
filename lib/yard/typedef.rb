# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

require 'shellwords'

# Project / Package
# -----------------------------------------------------------------------

require_relative "./typedef/version"
require_relative "./typedef/html_helper"


# Namespace
# =======================================================================

module  YARD


# Definitions
# =======================================================================

module  Typedef
  
  # Available helper modules by their format (as found in `options.format`).
  # 
  # We only cover `:html` for the moment, but may add more in the future.
  # 
  # @return [Hash<Symbol, Module>]
  # 
  HELPERS_BY_FORMAT = {
    html: HtmlHelper,
  }.freeze


  # The {Proc} that we add to {YARD::Templates::Template.extra_includes} on
  # {.install!}. The proc accepts template options and responds with the helper
  # module corresponding to the format (if any - right now we only handle 
  # `:html`).
  # 
  # We want this to be a constant so we can tell if it's there and
  # avoid ever double-adding it.
  # 
  # @return [Proc<YARD::Templates::TemplateOptions -> Module?>]
  # 
  HELPER_FOR_OPTIONS = proc { |options|
    HELPERS_BY_FORMAT[ options.format ]
  }.freeze
  
  
  # How typedef references start.
  # 
  # @return [::String]
  # 
  REF_START = '@type:'
  
  
  # {::Regexp} used to extract typedef references.
  # 
  # @see .extract_refs
  # 
  # @return [::Regexp]
  # 
  REF_REGEXP = \
    /#{ Regexp.escape REF_START }((?:::)?[A-Z][A-Za-z_]*(?:::[A-Z][A-Za-z_]*)*)/
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Add the {HELPER_FOR_OPTIONS} {Proc} to
  # {YARD::Templates::Template.extra_includes} (if it's not there already).
  # 
  # @see https://www.rubydoc.info/gems/yard/YARD/Templates/Template#extra_includes-class_method
  # 
  # @return [nil]
  # 
  def self.install!
    # NOTE  Due to YARD start-up order, this happens *before* log level is set,
    #       so the `--debug` CLI switch won't help see it... don't know a way to
    #       at the moment.
    log.debug "Installing `yard-typedef` plugin..."

    unless YARD::Templates::Template.extra_includes.include? HELPER_FOR_OPTIONS
      YARD::Templates::Template.extra_includes << HELPER_FOR_OPTIONS
    end

    nil
  end # .install!
  
  
  # @example Relative refs
  #   extract_refs "@type:Name"
  #   #=> [ "Name" ]
  #   
  #   extract_refs "@type:Some::Mod::Type"
  #   #=> [ "Some::Mod::Type" ]
  # 
  # @example Absolute refs
  #   extract_refs "@type:::Top::Mod::Type"
  #   #=> [ "::Top::Mod::Type" ]
  # 
  # @example Multiple refs
  #   extract_refs "Hash<@type:Name, @type:::Abs::Value> | @type:Other::Type"
  #   #=> [ "Name", "::Abs::Value", "Other::Type" ]
  # 
  # @example No refs
  #   extract_refs "::Hash<::Symbol, Some::Class>"
  #   #=> []
  # 
  # @param [::String] type
  #   Type string.
  # 
  def self.extract_refs type
    type.scan( REF_REGEXP ).flatten
  end
  
  
  def self.expand_refs template, types
    # This is how YARD tests if the list needs process, so I do the same
    return types unless types.is_a?( ::Array )
    
    return types
  end
  
  
  # Dump a hash of values as a `debug`-level log message (`log` is a global
  # function when you're hangin' in the YARD).
  # 
  # @example Dump values with a message
  #   obj = [ 1, 2, 3 ]
  #   
  #   dump "There was a problem with the ", obj, "object!",
  #     value_a: 'aye!',
  #     value_b: 'bzzz'
  # 
  # @example Dump values without a message
  #   dump value_a: 'aye!', value_b: 'bzzz'
  # 
  # @param [Array<String | Object>] message
  #   Optional log message. Entries will be space-joined to form the message 
  #   string: strings will be left as-is, and other objects will be
  #   stringified by calling their `#inspect` method. See examples.
  # 
  # @param [Hash<Symbol, Object>] values
  #   Map of names to values to dump.
  # 
  # @return
  #   Whatever `log.debug` returns.
  # 
  def self.dump *message, **values

    max_name_length = values.
      keys.
      map { |name| name.to_s.length }.
      max

    values_str = values.
      map { |name, value|
        name_str = "%-#{ max_name_length + 2 }s" % "#{ name }:"

        "  #{ name_str } #{ value.inspect } (#{ value.class })"
      }.
      join( "\n" )
    
    message_str = message.
      map { |part|
        case part
        when String
          part
        else
          part.inspect
        end
      }.
      join( " " )
    
    log_str = "Values:\n\n#{ values_str }\n"
    log_str = "#{ message_str }\n\n#{ log_str }" unless message_str.empty?

    log.debug "yard-typedef: #{ log_str }"
  end # .dump
  
end # module Typedef


# /Namespace
# =======================================================================

end # module YARD
