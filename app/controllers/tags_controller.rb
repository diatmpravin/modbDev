class TagsController < ApplicationController
  def index
    tags = current_account.tags.find(:all, :conditions => "name LIKE '#{params[:q]}%'")
    render :json => tags.map {|tag| tag.name}
  end
end
