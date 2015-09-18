class AddTotalToSymptomsSummaries < ActiveRecord::Migration
  def up
    SymptomSummary.transaction do
      add_column :symptoms, :symptom_summary_id, :integer
      add_column :symptom_summaries, :symptoms_count, :integer, default: 0

      symptom_summaries = []
      Symptom.uniq.pluck(:symptom).each do |s|
        symptom_summaries << SymptomSummary.new(symptom_name: s)
      end
      SymptomSummary.import symptom_summaries

      SymptomSummary.find_each do |ss|
        symptoms = Symptom.where(symptom: ss.symptom_name)
        symptoms.update_all symptom_summary_id: ss.id
      end

      SymptomSummary.reset_column_information
      SymptomSummary.find_each do |s|
        SymptomSummary.reset_counters s.id, :symptoms
      end
    end
  end

  def down

  end
end
