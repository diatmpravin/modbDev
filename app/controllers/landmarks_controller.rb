class LandmarksController < ApplicationController
  layout except_ajax('landmarks')
  
  def index
    @landmarks = current_account.landmarks
  end
  
end
