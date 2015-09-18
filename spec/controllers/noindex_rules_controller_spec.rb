require 'rails_helper'

RSpec.describe NoindexRulesController, :type => :controller do

  context 'user' do
    login_user
    describe 'POST create' do
      it 'returns http success' do
        post :create
        expect(response).to redirect_to('/')
      end
    end

    describe 'DELETE destroy' do
      it 'redirect to root path' do
        rule = FactoryGirl.create :noindex_rule
        delete :destroy, {id: rule.id}
        expect(response).to redirect_to('/')
      end
    end
  end

  context 'admin' do
    login_as_admin
    describe 'POST create' do
      it 'creates new noindex rule' do
        post :create, {format: :js, noindex_rule: {url: 'http://example.com'}}
        expect(NoindexRule.all.size).to eq(1)
      end
    end

    describe 'DELETE destroy' do
      it 'destroy certain rule' do
        rule = FactoryGirl.create :noindex_rule
        delete :destroy, {format: :js, id: rule.id}
        expect(NoindexRule.all.size).to eq(0)
      end
    end
  end


end
