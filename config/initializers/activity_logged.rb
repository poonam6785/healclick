require 'concerns/activity_logged'
require 'activity_logger'
ActiveRecord::Base.extend(ActivityLogged::ActiveRecord)