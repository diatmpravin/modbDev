/* Courtesy of http://brandonaaron.net/blog/2009/02/24/jquery-rails-and-ajax */
jQuery(document).ajaxSend(function(event, request, settings) {
  if (settings.type.toLowerCase() == 'post') {
    settings.data = (settings.data ? settings.data + "&" : "") +
      'authenticity_token=' + encodeURIComponent(Rails.authenticity_token);
  }
});