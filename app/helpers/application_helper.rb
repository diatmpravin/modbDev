module ApplicationHelper
  def jquery_include_tag
    javascript_include_tag 'jquery/jquery-1.4.2'
  end

  def mapquest_include_tags
    if Rails.env == 'development'
      javascript_include_tag mapquest_jsapi_url, 'mapquest/mqutils', 'mapquest/mqobjects', 'mapquest/mqexec'
    else
      javascript_include_tag mapquest_jsapi_url, 'mapquest/mqutils.min', 'mapquest/mqobjects.min', 'mapquest/mqexec.min'
    end
  end

  def mapquest_jsapi_url
    "http://btilelog.access.mapquest.com/tilelog/transaction?transaction=script&key=Gmjtd%7Clu6y216tng%2Crl%3Do5-lwa51&itk=true&v=5.3.s&ipkg=controls1,traffic&ipr=false"
  end

  # Called when setting the id of the main body tag
  def body_id
    params[:controller].parameterize
  end

  # Shortcut for showing any flash errors, warnings, and notices
  def messages
    render :partial => 'common/messages'
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

  # Central location for pagination options
  def paginate(collection)
    will_paginate(collection, :inner_window => 2)
  end

  # Google analytics
  def analytics
    return "" if Rails.env.development? || Rails.env.test?

    <<-END
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '#{Rails.env.production? ? "UA-6523957-6" : "UA-6523957-4"}']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
  })();

</script>
    END
  end
  
  # What tab should be active on this page?
  def active?(controller_name)
    if params[:controller] == controller_name
      ' class="active" '
    end
  end
end
