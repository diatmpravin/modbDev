module TagsHelper
  def preload_tags_json
    javascript_tag("Tags.source = #{current_account.tags.map {|t| t.name}.to_json};")
  end
end
