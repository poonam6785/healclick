class PatientMatchWorker
  def tag_query(table_name, tag, score)
    ["update #{table_name}",
      "inner join taggings on taggings.taggable_id = #{table_name}.to_user_id and taggings.taggable_type = 'User' and taggings.context= 'tags'",
      "inner join tags on tags.id = taggings.tag_id",
      "set score = score + #{score}",
      "where LOWER(tags.name) = '#{tag}';"].join(' ')
  end

  def run(for_patient)  
    return # Disable matching for now

    Rails.logger.debug 'PatientMatchWorker run'
    table_name = "patient_matches_run_#{for_patient.id}"

    # Drop any temporary tables with the same name if exist
    ActiveRecord::Base.connection.execute("drop temporary table if exists #{table_name};")

    # Create temporary table storing all the calculations
    create_table = ["create temporary table #{table_name}",
      "(score int(11) DEFAULT NULL,",
      "from_user_id int(11) DEFAULT NULL,",
      "to_user_id int(11) DEFAULT NULL);"].join(' ')
    ActiveRecord::Base.connection.execute(create_table)

    # Fill in with zeros
    zeros = ["insert into #{table_name} (from_user_id, to_user_id, score)",
    "select #{for_patient.id}, users.id, 0 from users where users.id != #{for_patient.id};"].join(' ')
    ActiveRecord::Base.connection.execute(zeros)

    # Add 6 points to those users who have at least one tag named as the patient's main condition
    main_condition = for_patient.main_condition.try(:name).try(:downcase).try(:strip)
    if main_condition.present?
      mainpoints = tag_query table_name, main_condition, 6
      ActiveRecord::Base.connection.execute(mainpoints)
    end

    # Add 5 points to those users who have at least one tag names as one of the patient's conditions
    conditions = for_patient.conditions.map { |condition| condition.try(:name).try(:downcase).try(:strip) }.compact
    (conditions || []).each do |condition|
      condition_points = tag_query table_name, condition, 5
      ActiveRecord::Base.connection.execute(condition_points)
    end


    # Add 3 points for each symptom
    symptoms = for_patient.symptoms.order(:rank).limit(10).to_a.map { |symptom| symptom.try(:symptom).try(:downcase).try(:strip) }.compact
    symptoms.each do |symptom|
      symptom_points = tag_query table_name, symptom, 3
      ActiveRecord::Base.connection.execute(symptom_points)
    end

    # Add 2 points for each subcategory
    subs = for_patient.sub_categories.map { |sub| sub.try(:name).try(:downcase).try(:strip) }.compact
    subs.each do |sub|
      sub_points = tag_query table_name, sub, 2
      ActiveRecord::Base.connection.execute(sub_points)
    end

    # Add 1 point for each category
    cats = for_patient.categories.map { |cat| cat.try(:name).try(:downcase).try(:strip) }.compact
    cats.each do |cat|
      cat_points = tag_query table_name, cat, 1
      ActiveRecord::Base.connection.execute(cat_points)
    end

    # Drop all matches with zero score
    ActiveRecord::Base.connection.execute("delete from #{table_name} where score = 0;")

    if for_patient.birth_date
      # Assign 3 point to users who have less than 5 years age difference
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.to_user_id",
          "set score = score + 3",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) < 5"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)

      # Assign 2 point to users who have more than 5 years age difference but less then 10
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.to_user_id",
          "set score = score + 2",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) between 5 and 9"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)

      # Assign 1 point to users who have more than 10 years age difference but less then 14
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.to_user_id",
          "set score = score + 1",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) between 10 and 13"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)
    end

    # Drop all previous matches for the patient
    PatientMatch.where(from_user_id: for_patient.id).delete_all
    # Copy all the new matches for the patient
    copy = ["insert into patient_matches (score, from_user_id, to_user_id, created_at, updated_at)",
      "select score, from_user_id, to_user_id, NOW(), NOW() from #{table_name};"].join(' ')
    ActiveRecord::Base.connection.execute(copy)

    # Drop the temporary table
    ActiveRecord::Base.connection.execute("drop temporary table #{table_name};")
  end

  def inverse_run(for_patient)
    return # Disable matching for now

    Rails.logger.debug 'PatientMatchWorker inverse run'
    table_name = "patient_matches_inverse_run_#{for_patient.id}"

    # Drop any temporary tables with the same name if exist
    ActiveRecord::Base.connection.execute("drop temporary table if exists #{table_name};")

    # Create temporary table storing all the calculations
    create_table = ["create temporary table #{table_name}",
      "(score int(11) DEFAULT NULL,",
      "from_user_id int(11) DEFAULT NULL,",
      "to_user_id int(11) DEFAULT NULL);"].join(' ')
    ActiveRecord::Base.connection.execute(create_table)

    # Fill in with zeros
    zeros = ["insert into #{table_name} (from_user_id, to_user_id, score)",
    "select users.id, #{for_patient.id}, 0 from users where users.id != #{for_patient.id};"].join(' ')
    ActiveRecord::Base.connection.execute(zeros)

    tags = for_patient.tags.map { |tag| tag.try(:name).try(:downcase).try(:strip) }.compact.uniq
    tags.each do |tag|
      #logger.debug tag

      # Add 6 points to users who have main condition matching to one of the tags of the patient
      main_condition_query = ["update #{table_name}",
       "inner join users on users.id = #{table_name}.from_user_id",
       "inner join conditions on users.main_condition_id = conditions.id",
       "set score = score + 6",
       "where lower(conditions.name) like '#{tag}'"].join(' ')
      ActiveRecord::Base.connection.execute(main_condition_query)

      # Add 5 points to those users who have at least one tag names as one of the patient's conditions
      conditions_query = ["update #{table_name}",
        "inner join user_conditions on user_conditions.user_id = #{table_name}.from_user_id",
        "inner join conditions on conditions.id = user_conditions.condition_id",
        "set score = score + 5",
        "where lower(conditions.name) like '#{tag}'"
      ].join(' ')
      ActiveRecord::Base.connection.execute(conditions_query)

      # Add 3 points for each symptom
      symptoms_query = ["update #{table_name}",
        "inner join symptoms on symptoms.user_id = #{table_name}.from_user_id",
        "set score = score + 3",
        "where lower(symptoms.symptom) like '#{tag}'"
      ].join(' ')
      ActiveRecord::Base.connection.execute(symptoms_query)

      # Add 2 points for each subcategory
      sub_query = ["update #{table_name}",
        "inner join symptoms on symptoms.user_id = #{table_name}.from_user_id",
        "inner join symptom_summaries on symptom_summaries.id = symptoms.symptom_summary_id",
        "inner join sub_categories on sub_categories.id = symptom_summaries.sub_category_id",
        "set score = score + 2",
        "where lower(sub_categories.name) like '#{tag}'"
      ].join(' ')
      ActiveRecord::Base.connection.execute(sub_query)

      # Add 1 point for each category
      cat_query = ["update #{table_name}",
        "inner join symptoms on symptoms.user_id = #{table_name}.from_user_id",
        "inner join symptom_summaries on symptom_summaries.id = symptoms.symptom_summary_id",
        "inner join sub_categories on sub_categories.id = symptom_summaries.sub_category_id",
        "inner join categories on sub_categories.category_id = categories.id",
        "set score = score + 1",
        "where lower(categories.name) like '#{tag}'"
      ].join(' ')
      ActiveRecord::Base.connection.execute(cat_query)
    end

    # Drop all matches with zero score
    ActiveRecord::Base.connection.execute("delete from #{table_name} where score = 0;")

    if for_patient.birth_date
      # Assign 3 point to users who have less than 5 years age difference
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.from_user_id",
          "set score = score + 3",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) < 5"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)

      # Assign 2 point to users who have more than 5 years age difference but less then 10
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.from_user_id",
          "set score = score + 2",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) between 5 and 9"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)

      # Assign 1 point to users who have more than 10 years age difference but less then 14
      peers_query = ["update #{table_name}",
          "inner join users on users.id = #{table_name}.from_user_id",
          "set score = score + 1",
          "where ABS(YEAR(users.birth_date) - #{for_patient.birth_date.year}) between 10 and 13"
        ].join(' ')

      ActiveRecord::Base.connection.execute(peers_query)
    end

    # Drop all previous matches for the patient
    PatientMatch.where(to_user_id: for_patient.id).delete_all

    # Copy all the new matches for the patient
    copy = ["insert into patient_matches (score, from_user_id, to_user_id, created_at, updated_at)",
      "select score, from_user_id, to_user_id, NOW(), NOW() from #{table_name};"].join(' ')
    ActiveRecord::Base.connection.execute(copy)

    # Drop the temporary table
    ActiveRecord::Base.connection.execute("drop temporary table #{table_name};")

    #for_users = []
    #for_patient.tags.each do |tag|
      #for_users << User.tagged_with(tag)
    #end
    #for_users = for_users.flatten.uniq

    #PatientMatch.where(to_user_id: for_patient.id).delete_all

    #matching_records = []
    #all_symptoms = Symptom.all.to_a
    #all_user_conditions = UserCondition.all.to_a
    #all_conditions = Condition.all.to_a

    ## Pe prima varianta calculam toate perechiile User.id, User.all.ids
    ## Pe a doua varianta calculam perechiile for_users.id, User.id
    #for_patient_tags = for_patient.tags.uniq
    
    #for_users.each do |user|
      #common_tags = [user.tags & for_patient_tags].uniq

      #if !common_tags.empty?
        #symptoms = all_symptoms.select{|x| x.user_id == user.id}.sort{|x,y| x.rank.to_i <=> y.rank.to_i}.first(10)
        #main_condition = all_conditions.select{|x| x.id == user.main_condition_id}.first
        #user_conditions = all_user_conditions.select{|x| x.user_id == user.id}

        #sub_categories = user.sub_categories
        #categories = user.categories
      #end

      #points = 0

      #if !common_tags.empty?
        #common_tags.flatten.each do |tag|      
          #if main_condition.present? && main_condition.name.present? && main_condition.name.to_s.downcase.strip == tag.name.downcase.strip
            #points += 6
          #elsif user_conditions.map(&:condition).map{|c| c.try(:name)}.compact.flatten.map(&:downcase).map(&:strip).flatten.include?(tag.name.downcase.strip)
            #points += 5
          #elsif symptoms.map(&:symptom).compact.flatten.map(&:downcase).map(&:strip).flatten.include?(tag.name.downcase.strip)
            #points += 3
          #elsif sub_categories.map(&:name).compact.flatten.map(&:downcase).map(&:strip).flatten.include?(tag.name.downcase.strip)
            #tags_count = sub_categories.map(&:name).compact.flatten.map(&:downcase).map(&:strip).flatten.count(tag.name.downcase.strip)
            #points += tags_count * 2
          #elsif categories.map(&:name).compact.flatten.map(&:downcase).map(&:strip).flatten.include?(tag.name.downcase.strip)
            #tags_count = categories.map(&:name).compact.flatten.map(&:downcase).map(&:strip).flatten.count(tag.name.downcase.strip)
            #points += tags_count
          #end
        #end
      #end

      #unless user.age.to_i == 0 || for_patient.age.to_i == 0

        #age_diff = user.age.to_i - for_patient.age.to_i

        #if (age_diff < 0)
          #age_diff = age_diff * -1
        #end

        #if age_diff >= 0 && age_diff < 5
          #points += 3
        #elsif age_diff >= 5 && age_diff < 10
          #points += 2
        #elsif age_diff >= 10 && age_diff < 14
          #points += 1
        #end        
      #end 

      #matching_records << PatientMatch.new(from_user_id: user.id, to_user_id: for_patient.id, score: points) if points != 0
    #end

    #PatientMatch.import matching_records

    #for_patient.patient_matches_to_users.update_all(patient_matches_updated_at: DateTime.now)
  end
end
