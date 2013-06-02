class UserMailer < ActionMailer::Base
  default from: "webmaster@hackerspace-adelaide.org.au"

  def user_signup_confirmation(user)
    @user = user
    @greeting = "Hello"
    mail(:to => user.email, :bcc => "adelaide.hackerspace@gmail.com", :subject => "Mappable - Welcome!")
  end

end
