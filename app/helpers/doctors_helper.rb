module DoctorsHelper
  def default_country
  	return params[:country_id] if params[:country_id].present?
  	return current_user.country_id if current_user
  end

  def doctors_period doctor
    return nil if doctor.started_on.blank?
    start_date = l(doctor.started_on, format: :month_year)
    end_date = if doctor.currently_seeing? || doctor.ended_on.blank?
      'Current'
    else
      l(doctor.ended_on, format: :month_year)
    end
    [start_date, end_date].join(' - ')
  end
end