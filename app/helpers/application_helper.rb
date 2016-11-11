# frozen_string_literal: true
module ApplicationHelper
  def custom_user
    if current_user.display_name.present?
      ", #{current_user.display_name}"
    end
  end

  def greetings
    ['Hey', 'Hello', 'Hi', 'Howdy', 'Bonjour', 'Good day', 'Aloha', 'Yo',
     'Namaste', 'Howdy-do', 'Cheerio', 'G\'day', 'Good day', 'Sup', 'Salute']
  end

  def greeting
    "#{greetings.sample}#{custom_user}!"
  end

  def owner?(event)
    current_user && event.user == current_user
  end
end
