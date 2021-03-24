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
  
  
  TAG_NAME = :typedef
  
  
  # How typedef references start.
  # 
  # @return [::String]
  # 
  REF_PREFIX = '@type:'
  
  
  # {::Regexp} used to extract typedef references.
  # 
  # @see .extract_names_from_refs
  # 
  # @return [::Regexp]
  # 
  REF_REGEXP = \
    /#{ Regexp.escape REF_PREFIX }((?:::)?[A-Z][A-Za-z_]*(?:::[A-Z][A-Za-z_]*)*)/
  
  
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

    YARD::Templates::Template.extra_includes << HELPER_FOR_OPTIONS
    
    YARD::Tags::Library.define_tag "Type Aliases", TAG_NAME, :with_types_and_name
    
    # This registered template works for yardoc
    YARD::Templates::Engine.register_template_path \
      ROOT.join( 'templates' ).to_s

    nil
  end # .install!
  
  
  # Extract typedef names from any references in a type string.
  # 
  # @example Relative refs
  #   extract_names_from_refs "@type:Name"
  #   #=> [ "Name" ]
  #   
  #   extract_names_from_refs "@type:Some::Mod::Type"
  #   #=> [ "Some::Mod::Type" ]
  # 
  # @example Absolute refs
  #   extract_names_from_refs "@type:::Top::Mod::Type"
  #   #=> [ "::Top::Mod::Type" ]
  # 
  # @example Multiple refs
  #   extract_names_from_refs "Hash<@type:Name, @type:::Abs::Value> | @type:Other::Type"
  #   #=> [ "Name", "::Abs::Value", "Other::Type" ]
  # 
  # @example No refs
  #   extract_names_from_refs "::Hash<::Symbol, Some::Class>"
  #   #=> []
  # 
  # @param [::String] type
  #   Type string.
  # 
  # @return [::Array<::String>]
  #   Extracted typedef names.
  # 
  def self.extract_names_from_refs type
    type.scan( REF_REGEXP ).flatten.uniq
  end
  
  
  def self.tag_by_name_from code_object, typedef_name
    tags = \
      code_object.tags( TAG_NAME ).select { |tag| tag.name == typedef_name }
    
    case tags.length
    when 0
      nil
    when 1
      tags[ 0 ]
    else
      log.warn "@typedef tag #{ typedef_name } defined multiple times in #{ code_object }"
      tags[ -1 ]
    end
  end
  
  
  def self.resolve_bare_name_from code_object, bare_name
    current = code_object
    
    until current == ::YARD::Registry.root
      if (tag = tag_by_name_from( current, bare_name ))
        return tag.types[ 0 ]
      end
      
      current = current.namespace
    end
    
    log.warn "Unable to resolve typedef ref #{ bare_name } in #{ code_object }"
    
    nil
  end
  
  
  def self.resolve_ref template, typedef_name
    typedef_namespace, _, bare_name = typedef_name.rpartition '::'
    
    if typedef_namespace == ''
      expansion = resolve_bare_name_from( template.object, bare_name )
      
      return typedef_name if expansion.nil?
      
      return "<emph>#{ expansion }</emph>"
    end
    
    typedef_namespace_object = \
      YARD::Registry.resolve template.object.namespace, typedef_namespace
    
    tag = tag_by_name_from typedef_namespace_object, bare_name
    
    return tag.types[ 0 ] if tag
    
    log.warn \
      "Unable to resolve typedef ref #{ typedef_name } in #{ template.object }"
    
    typedef_name
  end
  
  
  def self.expand_refs template, types
    # This is how YARD tests if the list needs process, so I do the same
    return types unless types.is_a?( ::Array )
    
    types.map do |type|
      extract_names_from_refs( type ).
        reduce( type ) { |type, typedef_name|
          type.gsub \
            "#{ REF_PREFIX }#{ typedef_name }",
            resolve_ref( template, typedef_name )
        }
    end
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
