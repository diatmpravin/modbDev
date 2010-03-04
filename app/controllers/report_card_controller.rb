class ReportCardController < ApplicationController

  layout except_ajax('devices')

  # GET /report_card
  # Main view of the report card
  def show
    @report_card = current_account.groups.of_devices.roots.map do |g|
      GroupSummaryReport.new(current_user, :group => g, :range => {:type => 1}).tap {|g| g.run }
    end
  end

end
