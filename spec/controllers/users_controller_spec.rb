require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe "GET 'time_series_analysis_admin'" do

    context 'admin' do
      login_as_admin
      it 'returns http success for admin' do
        FactoryGirl.create_list :user, 2
        get 'time_series_analysis_admin'
        expect(response).to be_success
      end
    end

    context 'user' do
      login_user
      it 'should redirects non-admin users' do
        FactoryGirl.create_list :user, 2
        get 'time_series_analysis_admin'
        expect(response).to redirect_to('/')
      end
    end

  end

end
