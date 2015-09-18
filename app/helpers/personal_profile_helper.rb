module PersonalProfileHelper
  def my_health_tabs
    %w(visualize symptoms treatments events labs doctors)
  end

  def get_actual_user(user, actual_user)

    if (user == actual_user) || !user.present?
      actual_user
    else
      user
    end

  end

  def options_for_graph_filter
    options_for_select [%w(Events events), %w(Treatments treatments), %w(Labs labs)]
  end
end