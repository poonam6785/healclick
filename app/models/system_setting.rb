class SystemSetting < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :value, presence: true
  serialize :value

  def self.get name
    where(:name => name).first_or_initialize
  end

  def self.get_value name, default_value = nil
    get(name).try(:value) || default_value
  end

  def self.get_values names
    values = {}
    where(:name => names).map do |setting|
      val = setting.try(:value)
      values[setting.name] = val if val.present?
    end
    values
  end

  def self.get_boolean_value name
    ['1', 'true'].include?(get_value(name).to_s.downcase)
  end
end