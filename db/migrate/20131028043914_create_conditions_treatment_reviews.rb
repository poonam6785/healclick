class CreateConditionsTreatmentReviews < ActiveRecord::Migration
  def change
    create_table :conditions_treatment_reviews, id: false do |t|
      t.references :condition      
      t.references :treatment_review
    end
  end
end
