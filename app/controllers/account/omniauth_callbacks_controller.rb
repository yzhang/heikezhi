class Account::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])
    @user ||= User.create_for_facebook_oauth(request.env["omniauth.auth"])
    sign_in @user
    flash[:success] = "Welcome to Swipe File! Please enter your email and desired screenname to complete registration."

    if params[:state].present?
      render 'post_signin', :layout => false
    else
      if current_user.email.blank? || current_user.screenname.blank?
        redirect_to setup_url
      else
        redirect_to swipes_url
      end
    end
  end

  def twitter
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"])
    @user ||= User.create_for_twitter_oauth(request.env["omniauth.auth"])
    sign_in @user
    flash[:success] = "Welcome to Swipe File! Please enter your email and desired screenname to complete registration."

    if params[:state].present?
      render 'post_signin', :layout => false
    else
      redirect_to setup_url
    end
  end
end
