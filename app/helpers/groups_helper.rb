module GroupsHelper

  # TODO (When Necessary): Improve performance by removing recursion
  def group_tree(groups, options = {})
    content_tag(:ol, groups.map { |g|
      content_tag(:li, "#{content_tag(:span, '', :class => 'checkbox')}
      #{content_tag(:span, '', :class => 'collapsible closed')}
      #{content_tag(:span, g.name, :class => 'name')}
      #{group_tree(g.children, options.merge(:style => 'display:none')) if g.children.any?}")
    }, options)
  end
  
end
