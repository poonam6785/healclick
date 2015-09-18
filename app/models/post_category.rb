class PostCategory < ActiveRecord::Base
	scope :not_for_guests, -> {where('name = ? OR name = ?', 'Social Support', 'Introductions')}
end
