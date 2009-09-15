class Admin::AdminController < ApplicationController
  # Change the meaning of "login_required" to reflect the Admin::Users
  # table, instead of the Accounts table.
  include AdminAuthenticatedSystem
  
  skip_before_filter :account_is_setup
  
  layout except_ajax('admin')
end