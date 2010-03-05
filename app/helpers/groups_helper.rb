module GroupsHelper

  # Create a group tree that allows the user to select a list of groups. Intended
  # to be used in conjunction with the ".groupSelect()" jQuery function.
  #
  # Options:
  #
  #   :checkbox  a string to be used as the field name of the checkboxes. If
  #              not included, checkboxes will be visible to the user, but not
  #              result in any form action on submit.
  #
  #   :selected  a list of groups already "selected" on the object you're
  #              working with. Leave this option out to start with no selected
  #              groups.
  #
  def group_tree(groups, options = {})
    options[:selected] ||= []
    options[:selected_ids] ||= options[:selected].map(&:id) 
    
    content_tag(:ol, groups.map { |g|
      content_tag(:li, [
        options[:checkbox] ? check_box_tag(options[:checkbox], g.id, options[:selected_ids].include?(g.id)) : nil,
        content_tag(:span, '', :class => 'checkbox'),
        content_tag(:span, '', :class => 'collapsible closed'),
        content_tag(:span, g.name, :class => 'name'),
        g.children.any? ? group_tree(g.children, options.merge(:style => 'display:none')) : nil
      ]) + '\n'
    }, {:style => options[:style]})
  end
  
end
