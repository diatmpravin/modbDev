module ApplicationHelper
  def jquery_include_tag
    if Rails.env == 'development'
      javascript_include_tag 'jquery/jquery-1.3.1'
    else
      javascript_include_tag 'jquery/jquery-1.3.1.min'
    end
  end

  def mapquest_include_tags
    if Rails.env == 'development'
      javascript_include_tag mapquest_jsapi_url, 'mapquest/mqutils', 'mapquest/mqobjects', 'mapquest/mqexec'
    else
      javascript_include_tag mapquest_jsapi_url, 'mapquest/mqutils.min', 'mapquest/mqobjects.min', 'mapquest/mqexec.min'
    end
  end

  def mapquest_jsapi_url
    "http://btilelog.access.mapquest.com/tilelog/transaction?transaction=script&key=mjtd%7Clu6y216tng%2Crl%3Do5-lwa51&itk=true&v=5.3.s&ipkg=controls1,traffic&ipr=false"
  end

  # Called when setting the id of the main body tag
  def body_id
    params[:controller]
  end

  # Courtesy of http://brandonaaron.net/blog/2009/02/24/jquery-rails-and-ajax
  def jquery_authenticity_token
    if protect_against_forgery?
      javascript_tag("Rails = {authenticity_token:'#{form_authenticity_token}'};") + javascript_include_tag('jquery/jquery.authenticity_token')
    end
  end

  # Shortcut for showing any flash errors, warnings, and notices
  def messages
    render :partial => 'layouts/messages'
  end

  # Shortcut for showing a checkmark
  def check_image(checked)
    checked ? image_tag('/images/checked.gif') : image_tag('/images/unchecked.gif')
  end

  # Shortcut for help tooltips
  def help_tooltip(partial_name)
    link_to('', '#', {
      :class => 'help',
      :title => render(:partial => "help_tooltips/#{partial_name}")
    })
  end

  # Takes a block and renders that block if the current user
  # has the required role.
  def requires_role(role)
    yield if current_user && current_user.has_role?(role)
  end
  
  # Little helper that should already exist
  def button_tag(value, options = {})
    tag 'input', {:type => 'button', :value => value}.merge(options)
  end
end