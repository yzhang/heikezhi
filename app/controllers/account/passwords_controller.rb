class Account::PasswordsController < Devise::PasswordsController
  layout "sessions"
  before_filter -> {@title = "Reset Password"}
end
