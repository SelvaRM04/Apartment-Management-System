class AdminsController < ApplicationController
  
  before_action :require_user, except: [ :new, :create ]
  before_action :set_admin, only: %i[ show edit update destroy ]

  # GET /admins or /admins.json
  def index
    @admins = Admin.all
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
        session[:user] = @admin.id
        session[:desig] = "Admin"
        format.html { redirect_to admin_url(@admin), notice: "Admin was successfully created." }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1 or /admins/1.json
  def update
    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to admin_url(@admin), notice: "Admin was successfully updated." }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
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
      format.html { redirect_to add_security_path, notice: "Security already exists" }
    else
      @security = Security.new(security_params)
      @apartment = Apartment.find(params["apartment_id"])
      @apartment.security = @security
      #  # debugger
        if @apartment.save
          format.html { redirect_to admin_url(session[:user]), notice: "Security was successfully created." }
        else
          # format.html { render :new, status: :unprocessable_entity }
          # format.json { render json: @owner.errors, status: :unprocessable_entity }
          format.html { redirect_to add_security_path, notice: @apartment.errors.full_messages }
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
end
