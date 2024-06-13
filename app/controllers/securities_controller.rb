class SecuritiesController < ApplicationController

  before_action :require_user, except: [ :new, :create ]
  before_action :set_security, only: %i[ show edit update destroy ]

  # GET /securities or /securities.json
  def index
    @securities = Security.all
    if session[:desig] != "Admin"
      respond_to do |format|
        flash[:alert] = "Invalid request"
        format.html { redirect_to "/home"} 
        format.json { head :no_content } 
      end
    end 
  end

  # GET /securities/1 or /securities/1.json
  def show
    if params[:id]
      if params[:id].to_i != session[:user] || session[:desig] != "Security"
        flash[:alert] = "Unauthorized request"
      end
      redirect_to "/home", :id => session[:user]
    else
      @messages = Message.where(from_id: session[:user]).or(Message.where(to_id: session[:user])).order(created_at: :desc)
      @messages_unread_count = 0
      @messages.each do |message|
        if message.status == false
          @messages_unread_count+=1
        end
      end
      @security = Security.find(session[:user])
      @blocks = Block.where(apartment_id: @security.apartment_id)
      @houses = []
      @blocks.each do |block|
        @houses << House.where(block_id: block.id)
      end
      @houses = @houses.flatten
    end
  end

  # GET /securities/new
  def new
    if params[:owner] != nil
      @security = Security.new(email:params[:security][:email], name:params[:security][:name], password:params[:security][:password])
    else
      @security = Security.new
    end
  end

  # GET /securities/1/edit
  def edit
    if params[:id] && session[:desig] == "Security"
      if params[:id].to_i != session[:user]
        flash[:alert] = "Invalid request"
        redirect_to "/home", :id => session[:user]
      else
        redirect_to "/edit"
      end
    end
  end

  # POST /securities or /securities.json
  def create

    @security_email = params["security"]["email"]
    @existing = Security.find_by(email: @security_email)
    respond_to do |format|
      if @existing == nil
        format.html { redirect_to new_security_path, notice: "Invalid Security email ID" }
        
      else
        @existing.name = params["security"]["name"]
        @existing.password = params["security"]["password"]
        if @existing.save
          session[:user] = @existing.id
          session[:desig] = "Security"
          format.html { redirect_to security_url(@existing), notice: "Security was successfully created." }
          format.json { render :show, status: :created, location: @existing }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @existing.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /securities/1 or /securities/1.json
  def update
    respond_to do |format|
      @updated_values = edit_params
      if @updated_values[:password]!="" && @updated_values[:new_password]!=""
        if @security.authenticate(@updated_values[:password])
          if @security.update(name: @updated_values[:name],email: @updated_values[:email],password: @updated_values[:new_password])
            format.html { redirect_to "/home", notice: "Security was successfully updated." }
          else
            format.html { redirect_to "/edit", alert: @security.errors.full_messages[0] }
          end
        else
          format.html { redirect_to "/edit", alert: "Incorrect Password entered" }
        end
      else
        if @owner.update(name: @updated_values[:name],email: @updated_values[:email])
          format.html { redirect_to "/home", notice: "Security was successfully updated." }
        else
          format.html { redirect_to "/edit", alert: @security.errors.full_messages[0] }
        end
      end
    end
  end

  # DELETE /securities/1 or /securities/1.json
  def destroy
    @security.destroy!

    respond_to do |format|
      format.html { redirect_to securities_url, notice: "Security was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_security
      if params[:id]
        @security = Security.find(params[:id])
      elsif session[:desig] == "Security"
        @security = Security.find(session[:user])
      end
    end

    # Only allow a list of trusted parameters through.
    def security_params
      params.require(:security).permit(:name, :email, :password)
    end

    def edit_params
      params.require(:security).permit(:name, :password, :new_password)
    end
end
