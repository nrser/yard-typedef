def init
  super()
  
  sections.place( :typedef_summary ).before( :constant_summary, true )
end


def typedef_summary
  tags = object.tags( ::YARD::Typedef::TAG_NAME ).sort_by { |tag| tag.name }
  
  return if tags.empty?
  
  @typedef_tags = tags
  erb :typedef_summary
end
