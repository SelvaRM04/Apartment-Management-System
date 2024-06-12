class SecuritiesController < ApplicationController
  before_action :set_security, only: %i[ show edit update destroy ]

  # GET /securities or /securities.json
  def index
    @securities = Security.all
  end

  # GET /securities/1 or /securities/1.json
  def show
    @messages = Message.where(from_id: session[:user]).or(Message.where(to_id: session[:user])).order(created_at: :desc)
    @messages_unread_count = 0
    @messages.each do |message|
      if message.status == false
        @messages_unread_count+=1
      end
    end
    @security = Security.find(params[:id])
    @blocks = Block.where(apartment_id: @security.apartment_id)
    @houses = []
    @blocks.each do |block|
      @houses << House.where(block_id: block.id)
    end
    @houses = @houses.flatten
  end

  # GET /securities/new
  def new
    @security = Security.new
  end

  # GET /securities/1/edit
  def edit
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
      if @security.update(security_params)
        format.html { redirect_to security_url(@security), notice: "Security was successfully updated." }
        format.json { render :show, status: :ok, location: @security }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @security.errors, status: :unprocessable_entity }
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
      @security = Security.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def security_params
      params.require(:security).permit(:name, :email, :password)
    end
end
