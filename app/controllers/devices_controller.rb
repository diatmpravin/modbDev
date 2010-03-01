class DevicesController < ApplicationController
  before_filter :require_role,   :only => [:create, :update, :destroy,
                                           :apply_profile, :apply_group, :remove_group]
  before_filter :set_device,     :only => [:edit, :update, :destroy, :show, :position]
  before_filter :set_devices,    :only => [:index]
  before_filter :require_access
  
  layout except_ajax('devices')

  def index
    respond_to do |format|
      format.html {
        @device = Device.new

        if request.xhr? && params[:page]
          render :partial => "list", :locals => {:devices => @devices}
        end
      }
      format.json {
        render :json => @devices.to_json(
          :methods => [:color, :connected],
          :include => {
            :position => {
              :methods => :time_of_day
            }            
          }
        )
      }
    end
  end
  
  def show
    respond_to do |format|
      format.html {
        render :action => 'edit'
      }
      format.json {
        render :json => [@device].to_json(
          :methods => [:color, :connected],
          :include => {
            :position => {
              :methods => :time_of_day
            }
          }
        )
      }
    end
  end
  
  def create
    if params[:imei].any? || params[:imei_confirmation].any? 
      if params[:imei] == params[:imei_confirmation]
        @device = current_account.devices.build(:name => params[:name])
        @device.user = current_user
        @device.tracker = Tracker.find_by_imei_number(params[:imei])

        if @device.tracker.nil?
          error = "Unknown Tracker"
        else
          if !@device.save
            error = @device.errors.full_messages
          end
        end
      else
        error = "Numbers do not match"
      end
    end
    
    if error
      render :json => {
        :status => 'failure',
        :error => error
      }
    else
      flash[:notice] = 'Vehicle added'
      render :json => {:status => 'success'}
    end
  end
  
  def edit
    respond_to do |format|
      format.html
      format.json {
        render :json => { :partial => render_to_string(:partial => 'form', :locals => {:device => @device}) }
      }
    end
  end
  
  def update
    params[:device][@device.id.to_s][:alert_recipient_ids] ||= []
    
    if @device.update_attributes(params[:device][@device.id.to_s])
      # Presumably, this needs to return to index with the CORRECT FILTER
      # and the CORRECT PAGE.
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @device.destroy
    
    respond_to do |format|
      format.html {
        redirect_to :action => 'index'
      }
      format.json {
        render :json => {:status => 'success'}
      }
    end
  end
  
  def position
    respond_to do |format|
      format.html
      format.json {
        render :json => @device.points.last
      }
    end
  end
 
  # I wish this method was on the DeviceProfile model, but then how do you
  # clear the profile?  DeviceProfile.new.apply(device)?  Seems a kluge.  -EN
  def apply_profile
    profile = current_account.device_profiles.find_by_id(params[:profile_id])

    # Apply the new profile to the selected devices 
    current_account.devices.update_all(
      {:device_profile_id => profile ? profile.id : nil},
      {:id => params[:apply_ids].split(',')}
    )
    
    # If the user wasn't clearing the profile, update all linked devices
    profile.update_devices unless profile.nil?
    
    redirect_to devices_path
  end

  # Given a group and list of device ids, add those devices to that group
  def apply_group
    group = 
      if params[:group_name] && params[:group_name].any?
        current_account.groups.of_devices.create :name => params[:group_name]
      else
        current_account.groups.of_devices.find(params[:group_id])
      end

    current_account.devices.find(params[:apply_ids].split(",")).each do |d|
      group.devices << d unless group.devices.include?(d)
    end

    redirect_to devices_path
  end

  # Given a gropu and a list of device ids, remove those devices from
  # the given group if those devices are in that group
  def remove_group
    group = current_account.groups.of_devices.find(params[:group_id])

    group.devices.delete(current_account.devices.find(params[:apply_ids].split(",")))

    redirect_to devices_path
  end

  # GET /devices/live_look?device_ids=
  # Given a list of device ids (comma seperated list)
  # show them on a live look map
  def live_look
    ids = params[:device_ids].split(',')
    if ids.empty?
      flash[:warning] = "Please select at least one vehicle to view on the map."
      redirect_to devices_path
      return
    end

    @devices = current_account.devices.find(ids)
    @device_ids = params[:device_ids]

    respond_to do |format|
      format.html { 
        render :layout => "maps"
      }
      format.json {
        render :json => @devices.to_json(
          :methods => [:color, :connected],
          :include => {
            :position => {
              :methods => :time_of_day
            }            
          }
        )
      }
    end
  end
  
  protected
  def require_role
    redirect_to root_path unless current_user.has_role?(User::Role::FLEET)
  end
  
  def require_access
    if @device && !current_user.can_edit?(@device)
      redirect_to root_path
    end
  end
  
  def set_device
    @device = current_account.devices.find(params[:id])
  end
  
  def set_devices
    @devices = search_on Device do
      current_account.devices.paginate :page => params[:page], :per_page => 30
    end
  end
end
