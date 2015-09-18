class AddMetaTagsContent < ActiveRecord::Migration
  def change

    if !ActiveRecord::Base.connection.table_exists?('meta_tags')
      create_table :meta_tags do |t|
        t.string :url
        t.string :title
        t.text :description
      
        t.timestamps
      end
    end  

    MetaTag.create(url: "conditions#index", title: "HealClick - Conditions", description: "Share treatment experiences with %disease_name patients.") 
    MetaTag.create(url: "users#index", title: "HealClick - Users", description: "Find Your Patient Match. Share What Treatments Worked.") 

  end
end
