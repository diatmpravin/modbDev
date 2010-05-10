class LandmarksController < ApplicationController
  require_role User::Role::LANDMARK
  before_filter :new_landmark, :only => [:new, :create]
  before_filter :set_landmark, :only => [:edit, :update, :destroy]
  
  layout except_ajax('landmarks')
  
  def index
    @landmarks = current_account.landmarks
    
    respond_to do |format|
      format.html {
        redirect_to dashboard_path(:anchor => 'landmarks')
      }
      
      format.json {
        render :json => @landmarks.to_json(index_json_options)
      }
    end
  end
  
  # def index
    # @landmarks = search_on Landmark do
      # current_account.landmarks.paginate(:page => params[:page], :per_page => 30)
    # end
    
    # respond_to do |format|
      # format.html {
        # if request.xhr? && params[:page]
          # render :partial => "list", :locals => {:landmarks => @landmarks}
        # end
      # }
    # end
  # end
  
  def new
  end
  
  def create
    save_record
  end
  
  def edit
  end
  
  def update
    save_record
  end
  
  def destroy
    @landmark.destroy
    
    render :json => {:status => 'success'}
  end
  
  protected
  
  def new_landmark
    @landmark = current_account.landmarks.new
  end
  
  def set_landmark
    @landmark = current_account.landmarks.find(params[:id])
  end
  
  def save_record
    if @landmark.update_attributes(params[:landmark])
      render :json => {
        :status => 'success',
        :landmark => @landmark
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => @landmark.new_record? ? 'new' : 'edit')
      }
    end
  end
  
  def index_json_options
    {:only => [:id, :name, :latitude, :longitude]}
  end
end
