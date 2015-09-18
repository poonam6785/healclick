class RegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    session.delete('referral') if session['referral'].present?
    root_url(protocol: :http)
  end

  private

    def sign_up_params
      allow = [:email, :first_name, :last_name, :username, :password, :password_confirmation, :login, :patient_or_caregiver, referral_attributes: [:link, :token]]
      params.require(resource_name).permit(allow)
    end

end