# This patch adds an easily recognizable class to the authenticity token
# container, allowing stylesheets to hide it and prevent odd UI bugs.
#
module ActionView::Helpers::FormTagHelper
  def extra_tags_for_form(html_options)
    case method = html_options.delete("method").to_s
    when /^get$/i # must be case-insentive, but can't use downcase as might be nil
      html_options["method"] = "get"
      ''
    when /^post$/i, "", nil
      html_options["method"] = "post"
      #protect_against_forgery? ? content_tag(:div, token_tag, :style => 'margin:0;padding:0') : ''
      protect_against_forgery? ? content_tag(:div, token_tag, :class => 'authenticityToken') : ''
    else
      html_options["method"] = "post"
      #content_tag(:div, tag(:input, :type => "hidden", :name => "_method", :value => method) + token_tag, :style => 'margin:0;padding:0')
      content_tag(:div, tag(:input, :type => 'hidden', :name => '_method', :value => method) + token_tag, :class => 'authenticityToken')
    end
  end
end