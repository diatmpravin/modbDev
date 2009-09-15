ExceptionNotifier.exception_recipients = %w{dev@crayoninterface.com}
ExceptionNotifier.sender_address = %("MOBD Exception" <error@gomoshi.com>)
ExceptionNotifier.email_prefix = "[MOBD #{Rails.env.capitalize}] "
