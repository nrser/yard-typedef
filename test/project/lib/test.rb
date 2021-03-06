# encoding: UTF-8
# frozen_string_literal: true

# @typedef [::Hash<::Symbol, ::Integer>] TopLevel
#   Try sticking something up here... which does *not* seem to get added to 
#   the root. Probably better actually.
# 


# The test module.
# 
# @typedef [::Symbol | ::String] Name
#   A name of something.
# 
# @typedef [::Proc<(@type:Name) → ::String>] Transformer
#   {::Proc} that transforms strings.
# 
module Test
  
  # Doesn't do anything.
  # 
  # @param [@type:Name] name1
  #   First name. It's a {type:Name}.
  # 
  # @param [@type:::Test::Name] name2
  # @param [@type:Test::Name] name3
  # 
  # @param [@type:Transformer] blah
  # @param [@alias:Transformer] blah
  # 
  # @return nil
  #  
  def self.do_something name1, name2, name3, blah
  end
  
  
  # @typedef [BlahType] Blah
  #   Blah!
  module ChildA
    
  end
  
  
  module ChildB
  
    # @param [@type:Name] name
    # @param [@type:ChildA::Blah] blah
    # 
    def self.something_else name, blah
    end
    
  end
  
end # module Test