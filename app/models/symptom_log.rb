class SymptomLog < ActiveRecord::Base
  belongs_to :symptom

  def name
    id
  end
end
