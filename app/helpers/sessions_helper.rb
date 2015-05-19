module SessionsHelper

  def signed_in_user
    unless signed_in?
      store_location
      flash[:warning] = "Please sign in."
      redirect_to signin_url
    end
  end
	
  #def sign_in(user)
  #	remember_token = User.new_remember_token
  #	cookies.permanent[:remember_token] = remember_token
  #	user.update_attribute(:remember_token, User.encrypt(remember_token))
  #	self.current_user = user
  #end

  #Logs in the given user
  def sign_in(user)
    session[:user_id] = user.id
  end

  #Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  #Returns true if the user is logged in, otherwise false
  def signed_in?
  	!current_user.nil?
  end

  #def sign_out
  #  return unless signed_in?
  #  current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
  #  cookies.delete(:remember_token)
  #  self.current_user = nil
  #end

  #Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  #Logs out the current user
  def sign_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user=(user)
  	@current_user = user
  end

  #def current_user
  #	remember_token = User.encrypt(cookies[:remember_token])
  #	@current_user ||= User.find_by(remember_token: remember_token)
  #end

  #Returns the user corresponding to the remember token cookie
  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        sign_in user
        @current_user = user
      end
    end
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

end
