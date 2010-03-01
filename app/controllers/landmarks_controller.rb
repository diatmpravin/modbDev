class LandmarksController < ApplicationController
  before_filter :new_landmark, :only => [:new, :create]
  before_filter :set_landmark, :only => [:show, :edit, :update, :destroy]
  
  layout except_ajax('landmarks')
  
  def index
    @landmarks = search_on Landmark do
      current_account.landmarks.paginate(:page => params[:page], :per_page => 30)
    end
    
    respond_to do |format|
      format.html
      format.json {
        render :text => @landmarks.to_json
      }
    end
  end
  
  def new
  end
  
  def create
    save_landmark(params[:landmark].first)
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    save_landmark(params[:landmark][@landmark.id.to_s])
  end
  
  def destroy
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
  
  def save_landmark(record)
    if @landmark.update_attributes(record)
      # Force lat & lng to load from db as valid floats (no lead/trail space,
      # etc.).  TODO: Better way to handle this situation?
      @landmark.reload
      
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
