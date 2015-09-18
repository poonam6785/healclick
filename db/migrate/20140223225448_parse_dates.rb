class ParseDates < ActiveRecord::Migration
  def up
    Treatment.find_each do |t|
      unless t.period.blank?
        started_on = nil
        ended_on = nil
        currently_taking = false
        period = t.period.gsub(/\s+/, '')
        currently_taking = true if !period['current'].nil? || !period['present'].nil?
        started_on_match = /\A(\d+)[-\\\/](\d+).*/.match(period)
        begin
          started_on = Date.parse("#{started_on_match[1]}/#{started_on_match[2]}") if !started_on_match.nil? && started_on_match[1].present? && started_on_match[2].present?
        rescue Exception => e
          next
        end

        # try to parse 2005 - current
        if started_on.blank?
          started_on_match = /\A(\d+)[-\\\/][current|present].*/.match(period)
          started_on = Date.parse("01/#{started_on_match[1]}") if !started_on_match.nil? && started_on_match[1].present?
        end

        # try to parse 2006, 2005, etc
        if period.size == 4
          started_on = "01/#{period}"
          currently_taking = true
        end

        unless currently_taking
          ended_on_match = /(\d+)[-\\\/](\d+)\Z/.match(period)
          begin
            ended_on = Date.parse("#{ended_on_match[1]}/#{ended_on_match[2]}") if !ended_on_match.nil? && ended_on_match[1].present? && ended_on_match[2].present?
          rescue Exception => e
            next
          end
        end

        currently_taking = true if ended_on.nil?

        unless started_on.blank?
          begin
            t.update_attributes started_on: started_on, currently_taking: currently_taking, ended_on: ended_on
          rescue => e
            puts "Could not update Treatment##{t.id}: #{e}"
          end
        end
      end
    end
  end

  def down

  end
end
