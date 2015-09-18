namespace :devise do 

  task haml: :environment do 
    Dir.entries(Rails.root.join('app', 'views', 'devise')).each do |folder|
      unless folder == '.' || folder == '..'
        files = Dir.entries(Rails.root.join('app', 'views', 'devise', folder))
        files.each do |file|
          if file =~ /erb$/
            filepath = Rails.root.join('app', 'views', 'devise', folder, file).to_s
            command = "html2haml -e #{filepath} #{filepath.gsub('erb', 'haml')}"
            system command
            File.unlink(filepath)
          end
        end
      end
    end
  end

end