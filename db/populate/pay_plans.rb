PayPlan.create_or_update(
  :id => 1,
  :name => "Annual",
  :description => "Charge you yearly",
  :period => 12,
  :public => true,
  :amount => "144.37",
  :period_description => "annual"
)

PayPlan.create_or_update(
  :id => 2,
  :name => "Monthly",
  :description => "Charge you every month",
  :period => 1,
  :public => true,
  :amount => "19.95",
  :period_description => "monthly"
)
