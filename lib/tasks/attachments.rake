namespace :attachments do
  task recompile: :environment do
    klass = ENV['klass'].classify.constantize
    style = ENV['style']
    klass.find_each do |item|
      begin
        item.attachment.reprocess!
        puts "Successfully processed #{style} for #{klass} ##{item.id}"
      rescue => e
        puts "Error processing #{klass} ##{item.id}: #{e.to_s}"
      end
    end
  end
end