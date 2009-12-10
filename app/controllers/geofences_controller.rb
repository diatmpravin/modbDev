class GeofencesController < ApplicationController

  layout :set_layout

  def index
    @geofences = search_on Geofence do
      current_account.geofences.paginate(:page => params[:page], :per_page => 30)
    end

    respond_to do |format|
      format.html
      format.json {
        render :json => @geofences
      }
    end
  end

  def new
    @geofence = Geofence.new
  end

  def create
    @geofence = current_account.geofences.build

    # If device ids or alert_recipient ids are missing, blank them out
    record = {:device_ids => [], :alert_recipient_ids => []}.merge(params[:geofence])

    if @geofence.update_attributes(record)
      redirect_to geofences_path
    else
      render :action => "new"
    end
  end

  def show
  end

  def edit
    @geofence = current_account.geofences.find(params[:id])
  end

  def update
    @geofence = current_account.geofences.find(params[:id])

    # If device ids or alert_recipient ids are missing, blank them out
    record = {:device_ids => [], :alert_recipient_ids => []}.merge(params[:geofence])

    if @geofence.update_attributes(record)
      redirect_to geofences_path
    else
      render :action => "edit"
    end
  end

  # DELETE /geofences/:id
  # Remove a geofence from the system
  def destroy
    current_account.geofences.destroy(params[:id])
    redirect_to geofences_path
  end

  protected

  def set_layout
    return nil if request.xhr?
    return "geofences_map" if [:edit, :new, :update, :create].include?(action_name.to_sym)
    "geofences"
  end
end
