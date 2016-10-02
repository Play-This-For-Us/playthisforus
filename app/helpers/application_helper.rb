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
    @eight_pm ||= Time.now.change(hour: 20 ).to_i
  end

  def greeting
    if midnight.upto(noon).include?(current_time)
      'Good Morning!'
    elsif noon.upto(five_pm).include?(current_time)
      'Good Afternoon!'
    elsif five_pm.upto(eight_pm).include?(current_time)
      'Good Evening!'
    elsif eight_pm.upto(midnight + 1.day).include?(current_time)
      'Good Night!'
    end
  end
end
