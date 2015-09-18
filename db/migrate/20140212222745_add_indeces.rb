class AddIndeces < ActiveRecord::Migration
  def change
    add_index :action_point_users, [:user_id, :action]
    add_index :activity_logs, [:user_id, :activity_id, :activity_type]
    add_index :conditions_treatment_summaries, :condition_id, name: 'cond_id'
    add_index :conditions_treatment_summaries, :treatment_summary_id, name: 'tr_summ_id'
    add_index :luvs, :luvable_id
    add_index :treatment_summaries, :latest_review_id
    add_index :treatments, [:condition_id, :treatment_summary_id]
  end
end
