class UserDecorator < Draper::Decorator
  delegate_all

  def minutes_to_unlock
    ((Devise.unlock_in.to_i - (Time.zone.now - locked_at).to_i) / 60).round
  end
end
