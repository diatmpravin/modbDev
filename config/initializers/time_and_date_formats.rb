# MM/DD/YYYY (default)
Date::DATE_FORMATS[:default] = '%m/%d/%Y'

# YYYY-MM-DD HH:MM:SS ZONE (default)
Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M:%S %Z'

# MM-DD-YYYY HH:MM PM ZONE (for trip displays)
Time::DATE_FORMATS[:trip] = '%m-%d-%Y %I:%M %p'

# HH:MM PM ZONE, MM-DD-YYYY (alert format)
Time::DATE_FORMATS[:alerts] = '%I:%M %p %Z, %m-%d-%Y'

# Local DATE (Month NN, YYYY)
Date::DATE_FORMATS[:local] = '%B %d, %Y'

# Local TIME (H:MM PM ZONE)
Time::DATE_FORMATS[:local] = '%I:%M %p %Z'