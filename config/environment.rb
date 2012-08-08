# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Bibtuck::Application.initialize!

# Date and Time Formats
Time::DATE_FORMATS[:bt_date_time] = "%m.%d.%y %l:%M%P"
Time::DATE_FORMATS[:bt_date] = "%m.%d.%y"
