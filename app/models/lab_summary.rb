class LabSummary < ActiveRecord::Base
  has_many :labs
  scope :with_labs, ->{where('labs_count > 0')}
  scope :by_count, ->{order('labs_count DESC')}
  scope :search, lambda{ |query| where('lower(lab) LIKE ?', "%#{query.to_s.downcase}%")}

  def self.names_with_counts
    pluck(:lab, :labs_count).map do |row|
      "#{row.first} (#{row.last})"
    end
  end
end