class LabLog < ActiveRecord::Base
  belongs_to :lab

  scope :not_blank, -> {where('current_value != ""')}
end