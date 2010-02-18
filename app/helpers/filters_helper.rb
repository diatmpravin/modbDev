module FiltersHelper

  # Helper method that adds a filter to the navbar, includes necessary javascripts
  # and defines the filter form to use.
  #
  # This method assumes that a 'filter_form' partial is located in your controller's
  # views folder. If you want to use a different form, define it in a block.
  def filter(&block)
    if block
      content_for :filter_form, capture(&block)
    else
      content_for :filter_form, render(:partial => "#{params[:controller]}/filter_form")
    end
    content_for :javascript, javascript_include_tag('filter')
    content_for :navbar, render(:partial => 'common/filter')
  end
end
