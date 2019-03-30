# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

require 'zlib'

# Deps
# ------------------------------------------------------------------------

require 'yard'

# Project / Package
# ------------------------------------------------------------------------


# Namespace
# ========================================================================

module  YARD
module  Typedef


# Definitions
# ========================================================================

# A helper module to add to {YARD::Templates::Template.extra_includes} to 
# override `#format_types` to handle resolving typedefs.
# 
# @see https://www.rubydoc.info/gems/yard/YARD%2FTemplates%2FTemplate.extra_includes
# 
module HtmlHelper

  # The {Proc} we pass to 
  # 
  # @return [Proc]
  # 
  INCLUDE_FILTER = proc do |options|
    HtmlHelper if options.format == :html
  end


   # Formats a list of types from a tag.
  #
  # @param [Array<String>, FalseClass] typelist
  #   the list of types to be formatted.
  #
  # @param [Boolean] brackets omits the surrounding
  #   brackets if +brackets+ is set to +false+.
  #
  # @return [String] the list of types formatted
  #   as [Type1, Type2, ...] with the types linked
  #   to their respective descriptions.
  #
  def format_types(typelist, brackets = true)
    return unless typelist.is_a?(Array)
    
    resolved_typelist = typelist.
      map { |type|
        if type.start_with? "@type:"
          typedef_name = type[ "@type:".length..-1 ]
          
          if (typedef = resolve_typedef( typedef_name ))
            typedef
          else
            log.warn "Unable to resolve typedef ref #{ type } in #{ object }"
            type
          end
        else
          type
        end
      }

    super( resolved_typelist, brackets )
  end

end # module HtmlHelper


# /Namespace
# ========================================================================

end # module Typedef
end # module YARD
