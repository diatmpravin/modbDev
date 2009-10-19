class LandmarksController < ApplicationController
  before_filter :new_landmark, :only => [:new, :create]
  before_filter :set_landmark, :only => [:show, :edit, :update, :destroy]
  before_filter :save_landmark, :only => [:create, :update]
  
  layout except_ajax('landmarks')
  
  def index
    @landmarks = current_account.landmarks
  end
  
  def new
  end
  
  def create
  end
  
  def show
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
    sleep 3
    @landmark.destroy
    
    respond_to do |format|
      format.json {
        render :json => {
          :status => 'success'
        }
      }
    end
  end
  
  protected
  def new_landmark
    @landmark = current_account.landmarks.new
  end
  
  def set_landmark
    @landmark = current_account.landmarks.find(params[:id])
  end
  
  def save_landmark
    record = params[:landmark][@landmark.new_record? ? 0 : @landmark.id.to_s]
    
    if @landmark.update_attributes(record)
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
            :html => render_to_string(
              :action => @landmark.new_record? ? 'new' : 'edit'
            )
          }
        }
      end
    end
  end
end
