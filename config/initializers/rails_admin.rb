# RailsAdmin config file. Generated on October 23, 2013 21:06
# See github.com/sferik/rails_admin for more informations

require 'rails_admin_emails'
require 'rails_admin_questionnaire'
require 'rails_admin_shop'
require 'rails_admin_seo'
require 'rails_admin_action_points'
require 'rails_admin_point_leaders'
require 'rails_admin_users_ranking'
require 'rails_admin_bulk_merge_symptom_summaries'
require 'rails_admin_merge_doctor_summaries'
require 'rails_admin_merge_post_categories'
require 'rails_admin_bulk_product_search_enable'
require 'rails_admin_bulk_edit_reviews'
require 'rails_admin_bulk_edit_treatments'
require 'rails_admin_bulk_edit_treatment_summaries'
require 'rails_admin_export_summaries'
require 'rails_admin_recover'
require 'rails_admin_edit_symptoms_for_summary'
require 'rails_admin_delete_category_children'
require 'rails_admin_delete_sub_category_children'
require 'rails_admin_export_duplicate_symptoms'
require 'rails_admin_version_stats'

RailsAdmin.config do |config|
  config.actions do
    # root actions
    dashboard                     # mandatory
    # collection actions 
    index                         # mandatory
    new
    export
    history_index
    bulk_delete
    # member actions
    show
    edit
    delete
    history_show
    show_in_app
    emails
    questionnaire
    shop
    seo
    export_summaries
    action_points
    point_leaders
    users_ranking
    version_stats
    bulk_merge_symptom_summaries do
      visible do
        bindings[:abstract_model].model.to_s == "SymptomSummary"
      end
    end
    bulk_product_search_enable do
      visible do
        bindings[:abstract_model].model.to_s == "TreatmentSummary"
      end
    end
    merge_doctor_summaries do
      visible do
        bindings[:abstract_model].model.to_s == "DoctorSummary"
      end
    end
    merge_post_categories do
      visible do
        bindings[:abstract_model].model.to_s == "PostCategory"
      end
    end

    bulk_edit_reviews do
      visible do
        bindings[:abstract_model].model.to_s == "Review"
      end
    end

    bulk_edit_treatment_summaries do
      visible do
        bindings[:abstract_model].model.to_s == "TreatmentSummary"
      end
    end

    bulk_edit_treatments do
      visible do
        bindings[:abstract_model].model.to_s == "Treatment"
      end
    end

    recover do
      visible do
        bindings[:abstract_model].model.to_s == "Post"
      end
    end

    edit_symptoms_for_summary do
      visible do
        bindings[:object].class.name == "SymptomSummary"
      end
    end

    export_duplicate_symptoms do
      visible do
        bindings[:abstract_model].model.to_s == "Symptom"
      end
    end

    delete_category_children do
      visible do
        bindings[:abstract_model].model.to_s == "Category"
      end
    end

    delete_sub_category_children do
      visible do
        bindings[:abstract_model].model.to_s == "SubCategory"
      end
    end

  end

  config.model User do
    list do
      field :id
      field :full_name
      field :username
      field :total_points
      field :created_at
      field :main_condition
      field :birth_date
      field :gender
      field :location
      field :bio
    end
    edit do
      configure :sub_categories do
        hide
      end
      configure :categories do
        hide
      end
    end
  end

  config.model TreatmentReview do
    list do
      field :id
      field :treatment do
        searchable [{Treatment => :treatment}]
        queryable true
      end
      field :content
      field :created_at
      field :updated_at
      field :conditions
      field :review
    end
  end

  config.model QuestionCategoriesUser do
    list do
      field :id
      field :user do
        searchable [{User => :username}]
        queryable true
      end
      field :question_category do
        searchable [{QuestionCategory => :name}]
        queryable true
      end
    end
  end

  config.model Post do
    list do
      field :id
      field :title
      field :content
      field :user do
        searchable [{User => :username}]
        queryable true
      end
      field :helpfuls_count
      field :comments_count
      field :created_at
      field :updated_at
      field :anonymous
      field :post_category
      field :interactions_count
      field :last_interaction_at
      field :views_count
      field :deleted_at
      field :locked
      field :treatment_review
      field :type
      field :treatment_level
      field :photo
      field :helpfuls
      field :comments
      field :post_followers
      field :conditions
    end
  end

  config.model Comment do
    list do
      field :id
      field :user do
        searchable [{User => :username}]
        queryable true
      end
      field :commentable
      field :parent
      field :content
      field :comments_count
      field :helpfulss_count
      field :created_at
      field :updated_at
      field :anonymous
      field :deleted
      field :attachment
      field :helpfuls
      field :comments
    end
  end

  config.model Answer do
    field :question_text
    field :username
    field :answer_text
    field :created_at
    list do
      field :user do
        searchable [{User => :username}]
        queryable true
      end
    end
  end


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = %w(Healclick Admin)
  config.current_user_method { current_user } # auto-generated
  config.excluded_models = %w(ActionPoints Message)
  config.navigation_static_links = {
    'Run Digest' => '/run_digest'
  }
end

require 'rails_admin_unscoped'