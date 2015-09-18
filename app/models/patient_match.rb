class PatientMatch < ActiveRecord::Base  
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User", touch: true

  validates :from_user_id, :to_user_id, :score, presence: true
end