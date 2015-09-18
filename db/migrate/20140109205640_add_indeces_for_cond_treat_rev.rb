class AddIndecesForCondTreatRev < ActiveRecord::Migration
  def change
    Condition.transaction do
      add_index :conditions_treatment_reviews, :condition_id
      add_index :conditions_treatment_reviews, :treatment_review_id
    end
  end
end
