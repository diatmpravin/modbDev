class GeofencesController < ApplicationController
  before_filter :new_geofence, :only => [:new, :create]
  before_filter :set_geofence, :only => [:edit, :update]
  before_filter :set_group, :only => [:index, :destroy, :update, :create]
  
  layout :set_layout

  def index
    unless @group.nil?
      list = @group.self_and_ancestors.map(&:id)
      
      group_geofences = current_account.geofences.all(:conditions => {:device_group_links => {:device_group_id => list} }, :joins => :device_groups)
      @geofences = group_geofences.paginate(:page=>params[:page], :per_page => 30)
    else
      @geofences = search_on Geofence do
        current_account.geofences.paginate(:page => params[:page], :per_page => 30)
      end
    end

    respond_to do |format|
      format.html
      format.json {
        render :json => @geofences
      }
    end
  end

  def new
  end

  def create
    save_record
  end

  def show
  end

  def edit
  end

  def update
    save_record
  end

  # DELETE /geofences/:id
  # Remove a geofence from the system
  def destroy
    current_account.geofences.destroy(params[:id])

    unless @group.nil?  
      redirect_to group_geofences_path(@group)
    else
      redirect_to geofences_path
    end
  end

  protected

  def new_geofence
    @geofence = current_account.geofences.new
  end
  
  def set_geofence
    @geofence = current_account.geofences.find(params[:id])
  end

  def set_group
    if (params[:group_id])
      @group = current_account.device_groups.find(params[:group_id])
    end
  end
  
  def set_layout
    return nil if request.xhr?
    #return "geofences_map" if [:edit, :new, :update, :create].include?(action_name.to_sym)
    "geofences"
  end
  
  def save_record
    # If group ids are missing, blank them out
    params[:geofence]['device_group_ids'] ||= []
    
    if @geofence.update_attributes(params[:geofence])
      unless @group.nil?
        redirect_to group_geofences_path(@group)
      else
        redirect_to geofences_path
      end
    else
      render :action => @geofence.new_record? ? 'new' : 'edit'
    end
  end
end
