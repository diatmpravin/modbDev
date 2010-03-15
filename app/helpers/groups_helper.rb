module GroupsHelper

  # Create a group tree by passing a parent group (or nil) and a block defining
  # how each element of the tree will look. The block will be passed a group object
  # and the current "level" of the tree. Level "0" is always the root node.
  #
  # Example:
  #   <% group_list(my_group) do |group, level| -%>
  #     <strong><%= group.name %></strong>
  #     <%= link_to 'Edit', edit_group_path(group) if level > 0 %>
  #   <% end -%>
  #
  # Options:
  #   :close_level  integer. levels below this level will start "closed"
  #   :include_parent  if true, the parent will be included in the tree
  #
  def group_tree(group, options = {}, level = 0, &block)
    options[:close_level] ||= 99
    options[:include_parent] ||= true
    
    if !group
      group = Struct.new(:id, :name, :children).new('', 'Root', current_account.groups.roots)
    end
    
    #if level == 0 && !options[:include_parent]
    #  concat(content_tag(:ol,
    #    group.children.map {|g| group_tree(g, options, level + 1, &block)}.join,
    #    level > options[:close_level] ? {:style => 'display:none'} : {}
    #  ))
    #  
    #  return
    #end
    li_options = level == 0 ? {:class => "root"} : {}
    
    html = content_tag(:li, [
      capture(group, level, &block),
      group.children.any? ? content_tag(:ol,
        group.children.map {|g| group_tree(g, options, level + 1, &block)}.join,
        level > options[:close_level] ? {:style => 'display:none'} : {}
      ) : nil
      ].join, li_options
    )
    
    level > 0 ? html : concat(content_tag(:ol, html))
  end
  
end
