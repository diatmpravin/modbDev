require 'test_helper'
describe 'Invoices Controller', ActionController::TestCase do
  use_controller InvoicesController

  setup do
    @account = accounts(:quentin)
    login_as :quentin
  end

  context 'viewing invoices' do
    specify 'works' do
      xhr :get, :index

      assigns(:invoices).length.should.not.be.nil
      template.should.be '_list'
    end

    specify 'requires BILLING role' do
      users(:quentin).update_attributes(:roles => [])
      login_as :quentin

      xhr :get, :index
      
      response.status.should.be 403
    end
  end
end
