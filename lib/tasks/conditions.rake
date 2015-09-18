namespace :conditions do 

  task create: :environment do 
    if Condition.count == 0
      Condition.create!(name: "Celiac")
      Condition.create!(name: "ME/CFS")
      Condition.create!(name: "Crohns Disease")
      Condition.create!(name: "Ehlers-Danlos syndrome")
      Condition.create!(name: "Fibromyalgia")
      Condition.create!(name: "Hashimoto's Disease")
      Condition.create!(name: "Hyperthyroidism")
      Condition.create!(name: "Hypothyroidism")
      Condition.create!(name: "Lyme Disease")
      Condition.create!(name: "Multiple Chemical Sensitivities")
      Condition.create!(name: "Multiple Sclerosis")
      Condition.create!(name: "POTS")
      Condition.create!(name: "Psoriasis")
      Condition.create!(name: "Reflex Sympathetic Dystrophy")
      Condition.create!(name: "Rheumatoid Arthritis")
      Condition.create!(name: "Sjogrens Syndrome")
      Condition.create!(name: "Systemic lupus erythematosus")
      Condition.create!(name: "Ulcerative Colitis")
      Condition.create!(name: "Other")      
    end
  end

  task posts: :environment do 
    Post.all.each do |p|
      unless p.is_a?(Review)
        if p.conditions.blank?
          puts "Post: #{p.id}"
          p.conditions << p.user.try(:main_condition) if p.user.try(:main_condition).present?
          unless p.user.blank?
            p.user.user_conditions.each do |uc|
              unless p.conditions.include?(uc.condition) || uc.condition.blank?
                p.conditions << uc.condition
              end
            end
            p.save
          end
        end
      end
    end
  end

end