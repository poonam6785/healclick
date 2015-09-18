module TreatmentsHelper
  def treatment_period(treatment)
    [l(treatment.started_on, format: :month_year), treatment.currently_taking? ? 'Current' : l((treatment.ended_on || Date.today), format: :month_year)].join(' - ')
  end

  def user_treatments_for_chart_filter(user)
    options_for_select([['Events', 'events'], ['No Treatment', 0, {'data-start' => nil, 'data-end' => nil}]] + user.treatments.map {|treatment|
      [treatment.treatment, treatment.id, {'data-start' => treatment.started_on, 'data-end' => treatment.ended_on}]
    })
  end

  def restore_treatment_values(treatment, date)
    date = Date.parse(date.to_s) if date.present?
    if date.present? && date <= Time.zone.now.to_date
      treatment_log = treatment.treatment_logs.order('treatment_logs.date desc').where('treatment_logs.date = ?', date).first.try(:attributes)
    end
    treatment_log ||= {}
    treatment_log.symbolize_keys
  end

  def options_for_graph(user = current_user)
    currently_taking = user.treatments.by_rank.currently_taking.map {|t| [t.treatment, t.id, {'data-start' => t.started_on, 'data-end' => t.ended_on}]}
    not_taking = user.treatments.by_rank.not_currently_taking.map {|t| [t.treatment, t.id, {'data-start' => t.started_on, 'data-end' => t.ended_on}]}
    options_for_select [['Select treatment', '']] + currently_taking + not_taking
  end

  def show_currently_taking?
    return false unless @date
    @date.to_date == Time.now.in_time_zone.to_date || @date.to_date == 1.day.from_now.in_time_zone.to_date
  end

  def labs_options_for_graph(user = current_user)
    options_for_select [['Select labs and other metrics', '']] + user.labs.map {|l| [l.name, l.id]}
  end

end