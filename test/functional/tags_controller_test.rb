require 'test_helper'

describe "Tags Controller", ActionController::TestCase do
  use_controller TagsController
  
  setup do
    login_as :quentin
    @account = accounts(:quentin)
  end
  
  context "Creating a tag" do
    specify "works" do
      Tag.should.differ(:count).by(1) do
        put :create, {
          :tag => {
            :name => 'My New Tag'
          }
        }
      end
      
      json['status'].should.equal 'success'
      @account.tags.reload.last.name.should.equal 'My New Tag'
    end
    
    specify "handles errors gracefully" do
      put :create, {
        :tag => {
          :name => ''
        }
      }
      
      json['status'].should.equal 'failure'
      json['error'].should.equal ['Name can\'t be blank']
    end
  end
end
