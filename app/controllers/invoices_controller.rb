class InvoicesController < ApplicationController
  require_role User::Role::BILLING

  def index
    @invoices = current_account.invoices

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => 'list'
        else
          redirect_to dashboard_path(:anchor => 'billing')
        end
      }
    end
  end
end
