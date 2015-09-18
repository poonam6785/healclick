namespace :post_categories do 

  task create: :environment do 
    PostCategory.create!(name: "Uncategorized")
    PostCategory.create!(name: "Diagnosis")
    PostCategory.create!(name: "Doctors")
    PostCategory.create!(name: "Fun")
    PostCategory.create!(name: "Introductions")
    PostCategory.create!(name: "Lifestyle Management")
    PostCategory.create!(name: "News and Research")
    PostCategory.create!(name: "Photo Contest")
    PostCategory.create!(name: "Products")
    PostCategory.create!(name: "Social Support")
    PostCategory.create!(name: "Symptoms")
    PostCategory.create!(name: "Tips")
    PostCategory.create!(name: "Treatment")
  end

end