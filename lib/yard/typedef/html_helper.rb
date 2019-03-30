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
  def format_types typelist, brackets = true
    super(
      ::YARD::Typedef.expand_refs( self, typelist ),
      brackets
    )
  end # #format_types

end # module HtmlHelper


# /Namespace
# ========================================================================

end # module Typedef
end # module YARD
