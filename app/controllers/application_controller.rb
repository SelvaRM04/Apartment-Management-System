class ApplicationController < ActionController::Base
   
    helper_method :current_user, :logged_in?

    def current_user
        if session[:desig]
            if session[:desig] == "Tenant"
                begin
                    @current_user = Tenant.find(session[:user])
                  rescue ActiveRecord::RecordNotFound => e
                    session[:user] = nil
                    session[:desig] = nil
                    flash[:alert] = "User has been deleted"
                    redirect_to '/home'
                  end
            elsif session[:desig] == "Owner"
                begin
                    @current_user = Owner.find(session[:user])
                  rescue ActiveRecord::RecordNotFound => e
                    session[:user] = nil
                    session[:desig] = nil
                    flash[:alert] = "User has been deleted"
                    redirect_to '/home'
                  end
            elsif session[:desig] == "Security"
                begin
                    @current_user = Security.find(session[:user])
                  rescue ActiveRecord::RecordNotFound => e
                    session[:user] = nil
                    session[:desig] = nil
                    flash[:alert] = "User has been deleted"
                    redirect_to '/home'
                  end
            elsif session[:desig] == "Admin"
                begin
                    @current_user = Admin.find(session[:user])
                  rescue ActiveRecord::RecordNotFound => e
                    session[:user] = nil
                    session[:desig] = nil
                    flash[:alert] = "User has been deleted"
                    redirect_to '/home'
                  end
            end
        end
    end
    
    def logged_in?
        !!current_user
    end

    def require_user
        if !logged_in?
            flash[:alert] = "You must be logged in to perform that action" 
            redirect_to root_path
        end
    end


end
