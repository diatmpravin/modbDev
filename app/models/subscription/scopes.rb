class Subscription < ActiveRecord::Base
  # Find all subscriptions to be billed on the given date
  named_scope :bill_on, lambda {|date|
    {
      :conditions => ["next_bill_date <= ? AND status != 'cancelled'", date], 
      :order => "next_bill_date ASC"
    }
  }

  # Find all yearly subscriptions who are 30 days from being charged
  named_scope :upcoming_annual_bill, lambda {|date|
    {
      :conditions => [
        "pay_plans.period = 12 AND next_bill_date = DATE(?)",
        30.days.from_now(date)
      ],
      :joins => :pay_plan
    }
  }

  # Find all subscriptions who are a month from an expired cc
  named_scope :month_from_cc_expiration, lambda {|date|
    { 
      :conditions => [
        "MONTH(:run_date) = expr_month AND " +
          "YEAR(:run_date) = expr_year AND " +
          "DAY(:run_date) = 1",{:run_date => date}
      ]
    }
  }

  # Find all subscriptions who are x days from cc expiration
  named_scope :days_from_cc_expiration, lambda {|date, days|
    {
      :conditions => [
        "DATE_ADD(:run_date, INTERVAL :days DAY) = "+
        "DATE_ADD(DATE(CONCAT_WS('-', expr_year, expr_month, 1)), INTERVAL 1 MONTH)",
          {:run_date => date, :days => days}
      ]
    }
  }

  # Find all subscriptions who's cc is expiring today
  named_scope :cc_expired, lambda {|date|
    {
      :conditions => [
        ":run_date = DATE_ADD(" +
            "DATE(CONCAT_WS('-', expr_year, expr_month, 1)), INTERVAL 1 MONTH)",
        {:run_date => date}
      ]
    }
  }
end
