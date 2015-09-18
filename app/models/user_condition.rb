class UserCondition < ActiveRecord::Base

  belongs_to :condition
  belongs_to :user

  after_create :reload_user

  scope :recent, lambda{ order('created_at desc') }

  has_paper_trail

  def reload_user
    user.save
  end

  def condition_name=(c)
    self.condition = Condition.find_by_name(c)
    if condition.blank?
      self.condition = Condition.create!(name: c, active: false, suggested: true)
    end
  end

  def condition_name
    condition.try(:name)
  end

  def condition
    Condition.unscoped { super }
  end
end