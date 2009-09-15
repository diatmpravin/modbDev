class TagsController < ApplicationController
  def create
    @tag = current_account.tags.build(params[:tag])
    
    if @tag.save
      render :json => {
        :status => 'success',
        :id => @tag.id,
        :name => @tag.name
      }
    else
      render :json => {
        :status => 'failure',
        :error => @tag.errors.map {|obj, err| "#{obj.humanize} #{err}"}
      }
    end
  end
end