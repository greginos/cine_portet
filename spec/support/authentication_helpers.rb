module AuthenticationHelpers
  def sign_in(admin_user)
    session[:admin_user_id] = admin_user.id
  end

  def sign_out
    session[:admin_user_id] = nil
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :controller
end
