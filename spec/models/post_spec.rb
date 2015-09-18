require 'rails_helper'

RSpec.describe Post, :type => :model do

  context 'Methods' do
    it 'should return true if category is FAQ or Blog' do
      faq_id = PostCategory.find_by_name('FAQ').id
      post = FactoryGirl.create :post, post_category_id: faq_id
      expect(post.faq_or_blog?).to be_truthy
    end
  end
end
