<%= f.hidden_field :type %>
<% fields_for :range, report.range do |f_r| -%>
  <%= f_r.hidden_field :type %>
  <%= f_r.hidden_field :start %>
  <%= f_r.hidden_field :end %>
<% end -%>
<% report.devices.each do |device| -%>
  <%= hidden_field_tag "devices[#{device.id}]", '1' %>
<% end -%>
