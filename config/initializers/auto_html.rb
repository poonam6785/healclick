AutoHtml.add_filter(:empty_lines).with({}) do |text, html_options|
  text = text.gsub(/\r\n/, "\n").gsub(/\n/, '<br />')
end

AutoHtml.add_filter(:youtube_custom).with(:width => 420, :height => 315, :frameborder => 0, :wmode => nil, :autoplay => false, :hide_related => false) do |text, options|
  regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]*)(\&\S+)?(\?\S+)?/
  text.sub(regex) do
    youtube_id = $3
    width = options[:width]
    height = options[:height]
    frameborder = options[:frameborder]
		wmode = options[:wmode]
    autoplay = options[:autoplay]
    hide_related = options[:hide_related]
		src = "//www.youtube.com/embed/#{youtube_id}"
    params = []
		params << "wmode=#{wmode}" if wmode
    params << "autoplay=1" if autoplay
    params << "rel=0" if hide_related
    src += "?#{params.join '&'}" unless params.empty?
    %{<iframe width="#{width}" height="#{height}" src="#{src}" frameborder="#{frameborder}" allowfullscreen></iframe>}
  end
end

AutoHtml.add_filter(:vimeo_custom).with(:width => 440, :height => 248, :show_title => false, :show_byline => false, :show_portrait => false) do |text, options|
  text.sub(/https?:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)((\?|#)\S+)?/) do
    vimeo_id = $2
    width  = options[:width]
    height = options[:height]
    show_title      = "title=0"    unless options[:show_title]
    show_byline     = "byline=0"   unless options[:show_byline]
    show_portrait   = "portrait=0" unless options[:show_portrait]
    frameborder     = options[:frameborder] || 0
    query_string_variables = [show_title, show_byline, show_portrait].compact.join("&")
    query_string    = "?" + query_string_variables unless query_string_variables.empty?

    %{<iframe src="//player.vimeo.com/video/#{vimeo_id}#{query_string}" width="#{width}" height="#{height}" frameborder="#{frameborder}"></iframe>}
  end

end

AutoHtml.add_filter(:remove_protocol_from_images) do |text|
  doc = Nokogiri::HTML(text)
  doc.css('img').each do |img|
    img['src'] = img['src'].gsub(/^https?:\/\//, '//')
  end
  doc.to_s
end