# frozen_string_literal: true
module ApplicationHelper
  def current_time
    @current_time ||= Time.now.to_i
  end

  def midnight
    @midnight ||= Time.now.beginning_of_day.to_i
  end

  def noon
    @noon ||= Time.now.middle_of_day.to_i
  end

  def five_pm
    @five_pm ||= Time.now.change(hour: 17).to_i
  end

  def eight_pm
    @eight_pm ||= Time.now.change(hour: 20).to_i
  end

  def custom_user
    if current_user.spotify_attributes.present? &&
       current_user.spotify_attributes.key?('display_name') &&
       !current_user.spotify_attributes['display_name'].empty?
      ", #{current_user.spotify_attributes['display_name']}"
    end
  end

  def greeting
    if midnight.upto(noon).include?(current_time)
      "Good Morning#{custom_user}!"
    elsif noon.upto(five_pm).include?(current_time)
      "Good Afternoon#{custom_user}!"
    elsif five_pm.upto(eight_pm).include?(current_time)
      "Good Evening#{custom_user}!"
    elsif eight_pm.upto(midnight + 1.day).include?(current_time)
      "Good Night#{custom_user}!"
    end
  end
end
