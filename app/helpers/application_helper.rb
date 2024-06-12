module ApplicationHelper
    def current_user
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
    
    def logged_in?
        !!current_user
    end
end
