module LabsHelper
  def lab_value_for_date(lab, value, date)
    lab.lab_logs.where(date: date).first.try(value)
  end
end