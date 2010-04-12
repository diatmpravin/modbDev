class MapController < ApplicationController
  layout except_ajax('internal')
  
  def show
    redirect_to report_card_path(:anchor => 'mapview')
  end
end
