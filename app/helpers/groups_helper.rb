module GroupsHelper

  def expandable?(group)
    (group.children + group.devices).length > 0
  end
  
  # Using the provided group, iterate non-recursively through its children and
  # construct a tree of groups and vehicles. The provided HTML block (required)
  # will be called with groups and vehicles as the list is created.
  #
  # The group given should be a DeviceGroup or DeviceGroup::Root object.
  #
  # Options:
  #   :close_level => which "level" to close. 0 is the root node
  #   :stop_level => which "level" to stop traversing at. 0 is the root node
  #   :root_ol => include root ol, default true
  def new_tree(group, options = {}, &block)
    options[:root_ol] = true if options[:root_ol].nil?
    options[:close_level] ||= 99
    options[:stop_level] ||= 99
    
    html = [[]]
    if options[:root_ol]
      pending = [:ol, :li, group, :nli, :nol]
      level = -1
    else
      pending = [:li, group, :nli]
      level = 0
    end
    
    while node = pending.shift
      case node
      when :ol
        html << []
        level += 1
      when :li
        html << []
      when :nli
        content = content_tag(:li, html.pop.join)
        html.last << content
      when :nol
        content = content_tag(:ol, html.pop.join)
        html.last << content
        level -= 1
      else
        html.last << capture(node, level, &block)
      end
      
      if !node.is_a?(Symbol) && !node.is_a?(Device)
        children = [:ol, (node.children + node.devices).map {|c| [:li, c, :nli]}, :nol]
        pending.unshift *(children.flatten)
      end
    end
    
    concat(html.to_s)
  end
  
  
  # Create a group tree by passing a parent group (or nil) and a block defining
  # how each element of the tree will look. The block will be passed a group object
  # and the current "level" of the tree. Level "0" is always the root node.
  #
  # Example:
  #   <% group_list(my_group) do |group, level| -%>
  #     <strong><%= group.name %></strong>
  #     <%= link_to 'Edit', edit_device_group_path(group) if level > 0 %>
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
      group = Struct.new(:id, :name, :children).new('', 'Root', current_account.device_groups.roots)
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
