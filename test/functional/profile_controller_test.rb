require 'test_helper'

describe "ProfileController", ActionController::TestCase do
  use_controller ProfileController

  setup do
    login_as :quentin
  end

  context "Show" do

    specify "shows edit form" do
      get :show
      template.should.be "show"

      assigns(:user).should.equal users(:quentin)
    end

  end

  context "Update" do

    specify "can update profile settings" do
      params = {
        :user => {
          :time_zone => "Mountain Time (US & Canada)"
        }
      }

      put :update, params
      should.redirect_to profile_path

      user = users(:quentin)
      user.reload
      user.zone.should.equal ActiveSupport::TimeZone["Mountain Time (US & Canada)"]
    end

    specify "can update security settings" do
      params = {
        :user => {
          :current_password => "test",
          :login => "testing",
          :login_confirmation => "testing",
          :password => "wootzor",
          :password_confirmation => "wootzor",
          :email => "test@example.com"
        }
      }

      u = users(:quentin)
      old_pass = u.crypted_password

      put :update, params
      should.redirect_to profile_path

      u.reload
      u.login.should.equal "testing"
      u.email.should.equal "test@example.com"
      u.crypted_password.should.not.equal old_pass
    end

    xspecify "security settings require current password" do
      params = {
        :user => {
          :login => "testing",
          :login_confirmation => "testing",
          :password => "wootzor",
          :password_confirmation => "wootzor",
          :email => "test@example.com"
        }
      }

      u = users(:quentin)
      old_pass = u.crypted_password

      put :update, params
      template.should.be "show"

      u.reload
      u.crypted_password.should.equal old_pass
    end

    specify "if password given, must match confirmation as well" do
      params = {
        :user => {
          :current_password => "test",
          :password => "wootzor",
          :password_confirmation => "failzor"
        }
      }

      u = users(:quentin)
      old_pass = u.crypted_password

      put :update, params
      template.should.be "show"

      u.reload
      u.crypted_password.should.equal old_pass
    end

  end

end
