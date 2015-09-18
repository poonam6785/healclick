class DoctorsController < ApplicationController

  before_filter :authenticate_user!, :find_doctor
  skip_before_filter :check_profile, :only => [:autocomplete, :create, :batch_create]

  def autocomplete
    if params[:query].length >= 3
      @doctors = DoctorSummary.search(params[:query]).order('reviews_count DESC')
    else
      @doctors = []
    end

    render json: @doctors.try(:names_with_counts)
  end

  def batch_create
    @errors = nil
    @doctors = []
    doctor_params[:name].split(',').each do |doctor|
      doctor = Doctor.new name: doctor, user_id: current_user.id
      if doctor.valid?
        doctor.save
        @doctors << doctor
      else
        @errors = doctor.errors.try(:[], :name).try(:first) if @errors.nil?
      end
    end
  end

  def update
    @doctor.update_attributes doctor_params
  end

  def destroy
    @doctor_id = @doctor.id
    summary = @doctor.doctor_summary
    @doctor.destroy
    summary.reload_numbers
  end

  def find_doctor
    @doctor = current_user.doctors.find(params[:id]) if params[:id].present?
  end

  def doctor_params
    params.require(:doctors).permit(:name, :recommended, :location, :period)
  end

end