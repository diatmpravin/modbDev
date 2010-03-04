module GroupsHelper

  # TODO (When Necessary): Improve performance by removing recursion
  def group_tree(groups)
    content_tag(:ol, groups.map { |g|
      content_tag(:li, "#{content_tag(:span, '', :class => 'checkbox')}
      #{content_tag(:span, '', :class => 'collapsible')}
      #{content_tag(:span, g.name, :class => 'name')}
      #{group_tree(g.children) if g.children.any?}")
    })
  end
  
end
