class NoindexRule < ActiveRecord::Base
  validates :url, presence: true
end
