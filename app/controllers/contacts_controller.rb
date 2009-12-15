class ContactsController < ApplicationController
  layout 'settings'

  def show
    # Contact form
  end

  # Sends an e-mail to our support address and one to the customer confirming
  # that we have received their e-mail.
  def create
    @subject = params[:subject]
    @body = params[:body]

    if(@subject.blank? || @body.blank?)
      flash[:error] = 'One or more of the fields have been left blank'
      flash.now

      render :action => :show
    else
      Mailer.deliver_contact_us(self.current_user, @subject, @body)
      Mailer.deliver_contact_us_confirmation(self.current_user, @subject, @body)

      flash[:notice] = 'Your mail has been sent.'

      redirect_to :action => :show
    end
  end
end
