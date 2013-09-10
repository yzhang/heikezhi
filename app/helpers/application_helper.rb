module ApplicationHelper
  def support_browser?
    user_agent =  request.env['HTTP_USER_AGENT'].downcase
    if user_agent.index('msie')
      false
    elsif user_agent.index('gecko/')
      false
    elsif user_agent.index('chrome/')
      true
    elsif user_agent.index('webkit/')
      true
    elsif user_agent.index('blink/')
      true
    else
      false
    end
  end
end
