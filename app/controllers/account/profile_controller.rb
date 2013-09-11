class Account::ProfileController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @profile = current_user.profile
    @title = 'Edit Profile'
    @user  = current_user
  end

  def update
    @profile = current_user.profile

    if @profile.update_attributes(profile_params)
      redirect_to '/mine'
    else
      render 'edit'
    end
  end
  
  private
  def profile_params
    params[:profile].permit(:bio, :twitter, :github, :google_plus)
  end
end
