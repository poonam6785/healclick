class MetaTag < ActiveRecord::Base
  validates :url, :title, :description, presence: true

  def self.display(params, fullpath)

    if fullpath.include?("conditions")
      m = MetaTag.find_by_url("conditions#index")
    else
      m = MetaTag.find_by_url("#{params[:controller]}##{params[:action]}")
    end

    return '','' unless m

    variables = { 
      :disease_name => ["Condition.find_by_slug(params[:condition_id]).try(:name)", 'any']}

    title = m.title
    description = m.description

    variables.each do |k, v|
      k_to_s = "%" + k.to_s
      if title.match(k_to_s)
        title = title.gsub(k_to_s, (eval(v[0]) or v[1]))
      end
      if description.match(k_to_s)
        description = description.gsub(k_to_s, (eval(v[0]) or v[1]))
      end
    end

    return title, description
  end
end
