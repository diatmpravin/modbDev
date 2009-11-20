require 'test_helper'

class RoutesTest < ActionController::IntegrationTest
  fixtures :all

  def path_for(options = {})
    url_for(options.merge(:only_path => true))
  end

  test "maps is root" do
    assert_equal "/", path_for(:controller => "maps", :action => "index")
  end
  
  test "accounts resources" do
    assert_equal "/accounts", accounts_path
    assert_equal "/accounts/1", account_path(1)
  end
  
  test "login/logout" do
    assert_equal "/login", login_path
    assert_equal "/logout", logout_path
  end

  test "maps resources" do
    assert_equal "/maps", maps_path
    assert_equal "/maps/1", map_path(1)

    assert_equal "/maps/status", status_maps_path
    assert_equal "/maps/1/status", status_map_path(1)
  end

  test "users resources" do
    assert_equal "/users", users_path
    assert_equal "/users/1", user_path(1)
    
    assert_equal "/users/resend_activation", resend_activation_users_path
    assert_equal "/users/forgot_password", forgot_password_users_path
    assert_equal "/users/reset_password", reset_password_users_path
    
    assert_equal "/users/1/activate", activate_user_path(1)
  end

  test "users have a profile" do
    assert_equal "/profile", profile_path
    assert_equal "/profile/edit", edit_profile_path
  end
  
  test "devices resources" do
    assert_equal "/devices", devices_path
    assert_equal "/devices/1", device_path(1)
    
    assert_equal "/devices/1/position", position_device_path(1)
    
    assert_equal "/devices/1/trips/2", device_trip_path(1, 2)
    assert_equal "/devices/1/geofences/2", device_geofence_path(1, 2)
  end
  
  test "trips resource" do
    assert_equal "/trips", trips_path
    assert_equal "/trips/1", trip_path(1)
    
    assert_equal "/trips/1/collapse", collapse_trip_path(1)
    assert_equal "/trips/1/expand", expand_trip_path(1)
  end

  test "geofences resource" do
    assert_equal "/geofences", geofences_path
    assert_equal "/geofences/1", geofence_path(1)
  end

  test "landmarks resources" do
    assert_equal "/landmarks", landmarks_path
    assert_equal "/landmarks/1", landmark_path(1)
  end
 
  test "tags resource" do
    assert_equal "/tags", tags_path
    assert_equal "/tags/1", tag_path(1)
  end

  test "reports resource" do
    assert_equal "/reports", reports_path
    assert_equal "/reports/1", report_path(1)
  end

  test "alert_recipients resource" do
    assert_equal "/alert_recipients", alert_recipients_path
    assert_equal "/alert_recipients/1", alert_recipient_path(1)
  end

  test "subscriptions resource" do
    assert_equal "/subscription", subscription_path
    assert_equal "/subscription/edit_plan", edit_plan_subscription_path
  end

  test "payments resource" do
    assert_equal "/payments", payments_path
    assert_equal "/payments/1", payment_path(1)
  end

  test "billing tester" do
    assert_equal "/billing_tester", billing_tester_path
    assert_equal "/billing_tester/action", billing_tester_path(:action => "action")
  end

  test "filter resource" do
    assert_equal "/filter", filter_path
  end
end
