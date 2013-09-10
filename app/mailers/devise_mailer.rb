# encoding: utf-8

class DeviseMailer < Devise::Mailer
  default :from => "黑客志<no-reply@heikezhi.com>"

  def reset_password_instructions(user, opt={})
    @user = user
    mail :to => @user.email, :subject => t(:reset_password_instruction),
         :template_path => 'mailer/users'
  end

  def confirmation_instructions(user, opts={})
    @user = user
    mail :to => @user.email, :bcc => 'zhangyuanyi@gmail.com',
         :subject => t(:confirm_instruction),
         :template_path => 'mailer/users'
  end
end