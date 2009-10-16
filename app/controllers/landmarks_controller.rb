class LandmarksController < ApplicationController
  layout except_ajax('landmarks')
  
  def index
    @landmarks = current_account.landmarks
  end
  
  def new
    @landmark = current_account.landmarks.new
  end
  
  def create
    @landmark = current_account.landmarks.new
    
    if @landmark.update_attributes(params[:landmark])
      respond_to do |format|
        format.json {
          render :json => {
            :status => 'success',
            :view => render_to_string(:action => 'show'),
            :edit => render_to_string(:action => 'edit')
          }
        }
      end
    else
      respond_to do |format|
        format.json {
          render :json => {
            :status => 'failure',
            :html => render_to_string(:action => 'new')
          }
        }
      end
    end
  end
  
  def show
  end
  
  def edit
  end
  
end
