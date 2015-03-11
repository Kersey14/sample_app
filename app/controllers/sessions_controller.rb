class SessionsController < ApplicationController

	def new
	end

	def create
	  user = User.find_by(email: params[:session][:email].downcase)
	  if user && user.authenticate(params[:session][:password])
	  	#Sign the user in and redirect to the user's show page
	  	sign_in user
	  	redirect_back_or user
	  else
	  	#create an error message and re-render the signin form
	  	flash.now[:danger] = 'Invalid email/password combination'
	  	render 'new'
	  end
	end

	def destroy
	  sign_out if signed_in?
  	  redirect_to '/signin'
	end

end
