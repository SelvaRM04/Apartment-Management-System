class ApplicationController < ActionController::Base
   
    helper_method :current_user, :logged_in?

    def current_user
        if session[:desig]
            if session[:desig] == "Tenant"
                @current_user = Tenant.find(session[:user])
            elsif session[:desig] == "Owner"
                @current_user = Owner.find(session[:user])
            elsif session[:desig] == "Security"
                @current_user = Security.find(session[:user])
            elsif session[:desig] == "Admin"
                @current_user = Admin.find(session[:user])
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
