class ReloadNumbers < ActiveRecord::Migration
  def change
    TreatmentSummary.all.each do |summary|
      summary.reload_numbers
    end
  end
end