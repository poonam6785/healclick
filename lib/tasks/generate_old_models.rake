namespace :old_models do 

  task generate: :environment do 
    list = File.readlines(Rails.root.join("lib", "assets", "old_models.txt"))
    list.each do |table_name|
      table_name = table_name.strip.gsub("\n", "")
      model_name = table_name.gsub(/t_/, '').gsub(/_hc$/, '').gsub("\n", "").to_s.strip.singularize
      class_name = model_name.camelize

      File.open(Rails.root.join("app", "old_models", "#{model_name}.rb"), 'a') do |f|
        f.write "class #{class_name} < ActiveRecord::Base\n\n"
        f.write "  establish_connection \"javadb\"\n\n"
        f.write "  self.table_name = '#{table_name}'\n\n"
        f.write "end"
      end

    end
  end

end