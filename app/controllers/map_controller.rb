class MapController < ApplicationController
  layout except_ajax('internal')
  
  def show
    redirect_to dashboard_path(:anchor => 'mapview')
  end
end
