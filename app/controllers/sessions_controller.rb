class SessionsController < ApplicationController
    def new
        if session[:user] && session[:desig]
            flash[:alert] = "Invalid request"
            redirect_to "/home"
        else
            @desig = params[:desig]
            if @desig == "owner"
                @user = Owner.new
            elsif @desig == "tenant"
                @user = Tenant.new
            elsif @desig == "security"
                @user = Security.new
            elsif @desig == "admin"
                @user = Admin.new
            end
        end
    end

    def create
        @desig = params[:desig]
        if @desig ==  "owner"
            @desig = "Owner"
            @user = Owner.find_by(email: params[:session][:email].downcase)
        elsif @desig == "tenant"
            @desig = "Tenant"
            @user = Tenant.find_by(email: params[:session][:email].downcase)
        elsif @desig == "security"
            @desig = "Security"
            @user = Security.find_by(email: params[:session][:email].downcase)    
        elsif @desig == "admin"
            @desig = "Admin"
            @user = Admin.find_by(email: params[:session][:email].downcase)                    
        end

        respond_to do |format|
            if @user && @user.authenticate(params[:session][:password])
                session[:user] = @user.id
                session[:desig] = @desig
                format.html { redirect_to "/home", notice: "Login successful" }
                # if @desig == "owner"
                #     session[:desig] = "Owner"
                #     format.html { redirect_to owner_path(@user.id), notice: "Login successful" }
                # elsif @desig == "tenant"
                #     session[:desig] = "Tenant"
                #     format.html { redirect_to house_path(@user.house_id), notice: "Login successful" }
                # elsif @desig == "security"
                #     session[:desig] = "Security"
                #     format.html { redirect_to security_path(@user), notice: "Login successful" }
                # elsif @desig == "admin"
                #     session[:desig] = "Admin"
                #     format.html { redirect_to admin_path(@user), notice: "Login successful" }
                # end
            else
                format.html { redirect_to login_path(params[:desig]), alert: "There is something wrong with your credentials. Try again!" }
            end
        end


    end

    def destroy
        respond_to do |format|
            session[:user] = nil
            session[:desig] = nil
            format.html { redirect_to root_path }
        end 
    end

end