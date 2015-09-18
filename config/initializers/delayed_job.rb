Delayed::Worker.default_priority = 5

class Delayed::Job < ActiveRecord::Base
  validate :check_for_handler, on: :create

  def check_for_handler
    q = YAML.load(self.handler)

    methods = [:populate_patient_matches_without_delay, :populate_patient_matches_inverse_without_delay, :remove_duplicates_patient_matches]
    return true unless methods.include?(q.method_name)

    Delayed::Job.pluck(:handler).each do |handler|
      a = YAML.load(handler)
      next unless methods.include?(a.method_name)
      
      if a.object.id == q.object.id && a.method_name == q.method_name
        errors.add(:base, 'Already a DJ for this user') and return false
      end
    end
    true
  end
end
