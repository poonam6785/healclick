module MessagesHelper

  def message_author_link(message, as_sender = false)
    user = message.from_user

    if user.present?
      (link_to(user_avatar(user, size: "60x60"), profile_url(user.username)) + 
      " " + 
      link_to(user.username, profile_url(user.username))).html_safe      
    else
      user_avatar(user, size: "60x60") + " No Name"
    end
  end

  def active_messages_tab(tab)
    return 'active' if tab == 'received' && !@composer_error && ((request.path == '/messages') || (@message.try(:to_user) == current_user))
    return 'active' if tab == 'sent' && !@composer_error && (((request.path == '/messages/sent') || (@message.try(:from_user) == current_user)) && request.path != '/messages/new')
    return 'active' if tab == 'compose' && ((request.path == '/messages/new') || @composer_error)
    return 'active' if tab == 'notifications' && request.path =~ /notifications/
  end

  def with_highlighted_links(text)
    auto_html text do
      link target: :_blank, rel: :nofollow
    end
  end

end