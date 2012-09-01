class UsersController < ApplicationController
  before_filter :check_login, :except => [:biz, :forgot, :destroy]

  def biz
    if logged_in?
      redirect_to root_path
      return
    end
    if params[:user]
      logout_keeping_session!
      @user = User.authenticate(params[:user][:email], params[:user][:password])
      if @user        
        session[@user.email] = nil

        self.current_user = @user
        # new_cookie_flag = (params[:remember_me] == "1")
        # handle_remember_cookie! new_cookie_flag
        redirect_back_or_default('/')
        flash[:notice] = nil
      else
        @new_user = User.find_by_email(params[:user][:email])
        if @new_user
          flash[:error] = "Please enter valid information"
        else
          @user = User.new(params[:user])
          if @user.email.blank? || @user.password.blank? || !check_emails(params[:user][:email])
            flash.now[:error] = "Wrong Username/Email and password combination."
          end

          success = @user && @user.valid?
          if success && @user.errors.empty?
            @user.save
            #NotifyMailer.signup(@user).deliver
            self.current_user = @user
            flash[:notice] = "Yeah, you now have an account. Wasn't that easy?"
            redirect_to('/')
            return
          end
        end
      end
    end
  end

  def forgot
    flash.discard
    if request.post?
      email = params[:email]
      if email.strip.blank?
        flash[:error] = "Please enter valid information"
        redirect_to :back
      else
        @user = User.find_by_email(email)
        if @user.nil?
          flash[:error] = "No such ID, want to join?"
          redirect_to :back
        else
          @user.email = "mailtoankitparekh@gmail.com"
          NotifyMailer.forgot(@user).deliver
          flash[:notice] = "Cool, emailed you the password"
          redirect_to root_path
        end
      end
    end
  end

  def profile
    @profile = current_user.profile if current_user.profile
    if request.post?
      @profile = (current_user.profile || Profile.new(params[:profile]))
      @profile.attributes = params[:profile]
      if @profile.errors.empty? and @profile.valid?
        # header color: 415F9B
        @profile.user = current_user
        @profile.save
        flash[:notice] = "Cool! Thanks for saving your profile."
        redirect_to root_path
      else
        flash[:error] = "Please enter valid information"
      end
    end
  end

  def destroy
    logout_killing_session!
    session[:user_id] = nil
    flash[:notice] = "Thanks for stopping by. You all come back soon!"
    redirect_back_or_default('/')
  end
end
