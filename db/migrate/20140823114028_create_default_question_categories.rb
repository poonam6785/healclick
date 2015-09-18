class CreateDefaultQuestionCategories < ActiveRecord::Migration
  def up
    QuestionCategory.create name: 'Abdominal or belly pain', slug: 'abdominal'
    QuestionCategory.create name: 'Difficulty swallowing', slug: 'swallowing'
    QuestionCategory.create name: 'Bowel incontinence (have an accident or soil underclothes)', slug: 'bowel'
    QuestionCategory.create name: 'Heartburn, acid reflux, or gastroesophageal reflux', slug: 'heartburn'
    QuestionCategory.create name: 'Bloating or swelling in your belly', slug: 'bloating'
    QuestionCategory.create name: 'Diarrhea (loose, watery, or frequent stools)', slug: 'diarrhea'
    QuestionCategory.create name: 'Constipation (hard, lumpy, or infrequent stools; straining)', slug: 'constipation'
    QuestionCategory.create name: 'Nausea or vomiting', slug: 'nausea'
    QuestionCategory.create name: 'None of these symptoms have recently been especially bothersome', slug: 'none'
  end

  def down
    QuestionCategory.all.destroy_all
  end
end
