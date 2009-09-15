require 'test_helper'

describe "WithActiveRecord", ActiveSupport::TestCase do
  include WithActiveRecord
  
  specify "works" do
    with_active_record do
      Account.find(accounts(:quentin).id).should.equal accounts(:quentin)
    end
  end
end
