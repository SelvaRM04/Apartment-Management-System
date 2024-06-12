class SessionsController < ApplicationController
    def new
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

    def create
        @desig = params[:desig]
        if @desig ==  "owner"
            @user = Owner.find_by(email: params[:session][:email].downcase)
        elsif @desig == "tenant"
            @user = Tenant.find_by(email: params[:session][:email].downcase)
        elsif @desig == "security"
            @user = Security.find_by(email: params[:session][:email].downcase)    
        elsif @desig == "admin"
            @user = Admin.find_by(email: params[:session][:email].downcase)                    
        end

        respond_to do |format|
            if @user && @user.authenticate(params[:session][:password])
                session[:user] = @user.id
                if @desig == "owner"
                    session[:desig] = "Owner"
                    format.html { redirect_to owner_path(@user.id), notice: "Login successful" }
                elsif @desig == "tenant"
                    session[:desig] = "Tenant"
                    format.html { redirect_to house_path(@user.house_id), notice: "Login successful" }
                elsif @desig == "security"
                    session[:desig] = "Security"
                    format.html { redirect_to security_path(@user), notice: "Login successful" }
                elsif @desig == "admin"
                    session[:desig] = "Admin"
                    format.html { redirect_to admin_path(@user), notice: "Login successful" }
                end
            else
                format.html { redirect_to login_path(@desig), notice: "There is something wrong with your credentials. Try again!" }
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