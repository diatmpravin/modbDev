module GroupsHelper

  # Create a group tree by passing a list of groups and a block defining how
  # each element of the tree should look. The block will be passed a group object
  # and the current "level" of the tree.
  #
  # Example:
  #   <% group_list(my_groups) do |group, level| -%>
  #     <strong><%= group.name %></strong>
  #     <%= link_to 'Edit', edit_group_path(group) %>
  #   <% end -%>
  #
  # Options:
  #   :closed  if true, non-root elements will start out hidden (false by default)
  #
  def group_tree(groups, options = {}, level = 0, &block)
    if level == 0
      # Get the "roots" of this collection (not necessarily true roots)
      # Do this the math way, to avoid hitting the database for each group
      rgt = 0
      groups -= groups.sort {|x,y| x.lft <=> y.lft}.select {|g|
        rgt = [rgt, g.rgt].max ; g.rgt < rgt
      }
    end
    
    tree = content_tag(:ol, groups.map { |g|
      content_tag(:li, [
        capture(g, level, &block),
        g.children.any? ? group_tree(g.children, options, level + 1, &block) : nil
      ].join)
    }, options[:closed] && level > 0 ? {:style => 'display:none'} : {})
    
    level > 0 ? tree : concat(tree)
  end
  
end
