class Account::SessionsController < Devise::SessionsController
  layout "sessions"

  def new
    @title = "Login"
    render layout: 'sessions'
  end

  def forgot_password
    @title = "Forgot Password"
  end

  def send_reset_instruction
    user = User.where("email is not null and email <> ''").where(:email => params[:user][:email]).first

    if user
      user.delay.send_reset_password_instructions
      flash[:notice] = "Reset instructions has been sent to your inbox."
      redirect_to '/signin'
    else
      flash[:notice] = "Sorry, we can't find your account."
      render 'forgot_password'
    end
  end
end
