module HomeHelper

  def feed_filter_options
    options = []
    options << ['All Updates', 'all', data: {url: url_for(params.merge(filter: 'all'))}]
    options << ['Posts Only', 'posts', data: {url: url_for(params.merge(filter: 'posts'))}]
    options << ['Photos Only', 'photos', data: {url: url_for(params.merge(filter: 'photos'))}]
    options << ['Tracking Updates Only', 'tracking', data: {url: url_for(params.merge(filter: 'tracking'))}]
  end
end
