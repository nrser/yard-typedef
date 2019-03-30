# encoding: UTF-8
# frozen_string_literal: true

##############################################################################
# Plugin Entry Point for YARD
# ============================================================================
# 
# While the library itself lives in the `YARD::StdLib` namespaces under the
# usual directory structure of `//lib/yard/typedef`, when requiring
# plugins YARD will reach for `yard-typedef`, basically just calling
# 
#     require 'yard-typedef'
# 
# which leads it here. This is nice, because it lets us use the kind-of funkily
# 
##############################################################################


require_relative "./yard/typedef"

YARD::Typedef.install!
