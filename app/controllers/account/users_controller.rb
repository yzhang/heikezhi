class Account::UsersController < Devise::RegistrationsController
  def edit
    @user = current_user
  end
end
