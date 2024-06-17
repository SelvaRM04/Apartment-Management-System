class AdminsController < ApplicationController
  
  before_action :require_user, except: [ :new, :create ]
  before_action :set_admin, only: %i[ show edit update destroy ]

  # GET /admins or /admins.json
  def index
    @admins = Admin.all
    if session[:desig] != "Admin"
      flash[:alert] = "Invalid request"
      redirect_to "/home"
    end
  end

  # GET /admins/1 or /admins/1.json
  def show
    
    if params[:id]
      if params[:id].to_i != session[:user] || session[:desig] != "Admin"
        flash[:alert] = "Unauthorized request"
      end
      redirect_to "/home", :id => session[:user]
    else
      @houses = []
      @apartments = Apartment.all
      @apartments.each do |apartment|
        @blocks = apartment.blocks
        @blocks.each do |block|
          @houses << block.houses
        end
      end
      @houses = @houses.flatten()
      @securities = Security.all
    end
  end

  # GET /admins/new
  def new
    @admin = Admin.new
    if session[:desig] != "Admin"
      flash[:alert] = "Invalid request"
      redirect_to "/home"
    end
  end

  # GET /admins/1/edit
  def edit
  end

  # POST /admins or /admins.json
  def create
    @admin = Admin.new(admin_params)
    #  # debugger
    respond_to do |format|
      if @admin.save
        format.html { redirect_to "/home", notice: "Admin was successfully created." }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { redirect_to new_admin_path(:type => "add"), alert: @admin.errors.full_messages[0] }
      end
    end
  end

  # PATCH/PUT /admins/1 or /admins/1.json
  def update
    respond_to do |format|
      @updated_values = edit_params
      if @updated_values[:password]!="" && @updated_values[:new_password]!=""
        if @admin.authenticate(@updated_values[:password])
          if @admin.update(name: @updated_values[:name],email: @updated_values[:email],password: @updated_values[:new_password])
            format.html { redirect_to "/home", notice: "Admin was successfully updated." }
          else
            format.html { redirect_to "/edit", alert: @admin.errors.full_messages[0] }
          end
        else
          format.html { redirect_to "/edit", alert: "Incorrect Password entered" }
        end
      else
        if @admin.update(name: @updated_values[:name],email: @updated_values[:email])
          format.html { redirect_to "/home", notice: "Admin was successfully updated." }
        else
          format.html { redirect_to "/edit", alert: @admin.errors.full_messages[0] }
        end
      end
    end
  end

  # DELETE /admins/1 or /admins/1.json
  def destroy
    @admin.destroy!

    respond_to do |format|
      format.html { redirect_to admins_url, notice: "Admin was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_security
    if session[:desig] != "Admin"
      respond_to do |format|
        flash[:alert] = "Invalid request"
        format.html { redirect_to "/home"} 
        format.json { head :no_content } 
      end
    else
      @security = Security.new
    end
  end

  def add 
    respond_to do |format|
    @existing = Security.find_by(email: params["email"])
    #  # debugger
      if(@existing != nil)
        format.html { redirect_to add_security_path, alert: "Security already exists" }
      else
        @security = Security.new(security_params)
        @apartment = Apartment.find(params["apartment_id"])
        if @apartment.security != nil
          format.html { redirect_to add_security_path, alert: "Apartment has a security already" }
        else
          @apartment.security = @security
          #  # debugger
          if @apartment.save
            format.html { redirect_to "/home", notice: "Security was successfully created." }
          else
            # format.html { render :new, status: :unprocessable_entity }
            # format.json { render json: @owner.errors, status: :unprocessable_entity }
            format.html { redirect_to add_security_path, notice: @apartment.errors.full_messages }
          end
        end
      end
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      if params[:id]
        @admin = Admin.find(params[:id])
      elsif session[:desig] == "Admin"
        @admin = Admin.find(session[:user])
      end
    end

    # Only allow a list of trusted parameters through.
    def admin_params
      params.require(:admin).permit(:name, :email, :password)
    end

    def security_params
      params.permit(:email, :apartment).merge(password: "Security")
    end

    def email_param
      params.permit(:email)
    end

    def edit_params
      params.require(:admin).permit(:name, :email, :password, :new_password)
    end
end
