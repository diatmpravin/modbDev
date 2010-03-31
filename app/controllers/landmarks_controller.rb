class LandmarksController < ApplicationController

  layout except_ajax('landmarks')
  
  def index
    respond_to do |format|
      format.html
      
      format.json {
      
    # TODO: Put this somewhere more global
    ActiveRecord::Base.include_root_in_json = false
    
    @landmarks = current_account.landmarks
    
    
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
  
  # GET /landmarks/new
  def new
    @landmark = Landmark.new
  end
  
  # POST /landmarks
  # Create a new landmark
  def create
    @landmark = current_account.landmarks.build(params[:landmark])

    if @landmark.save
      flash[:notice] = "Landmark created"
      redirect_to landmarks_path
    else
      render :action => "new"
    end
  end
  
  # GET /landmarks/:id/edit
  def edit
    @landmark = current_account.landmarks.find(params[:id])
  end
  
  # PUT /landmarks/:id
  # Update an existing landmark
  def update
    @landmark = current_account.landmarks.find(params[:id])

    if @landmark.update_attributes(params[:landmark])
      flash[:notice] = "Landmark updated"
      redirect_to landmarks_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    current_account.landmarks.destroy(params[:id])

    redirect_to landmarks_path
  end
  
  protected
  
  def index_json_options
    {:only => [:id, :name, :latitude, :longitude]}
  end
end
