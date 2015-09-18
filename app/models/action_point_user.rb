class ActionPointUser < ActiveRecord::Base
  belongs_to :user

  attr_accessor :manual_created_at

  after_create :change_created_at

  private

  def change_created_at
    unless manual_created_at.blank?
      self.update_column :created_at, self.manual_created_at
    end
  end
end
