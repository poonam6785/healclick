class PopulateDateForEvents < ActiveRecord::Migration
  def up
    Event.transaction do
      Event.where(date: nil).find_each do |event|
        event.update_attributes(date: event.created_at.to_date)
      end
    end
  end
end
