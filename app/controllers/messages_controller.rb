class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Message.where(from_id: session[:user]).or(Message.where(to_id: session[:user])).order(created_at: :desc)
    @image_show = false
  end

  # GET /messages/1 or /messages/1.json
  def show
    @image_show = true
    @status = Message.find(@message.id)
    @status.status = true;
    @status.save
    # if @message.to_desig == "tenant"
    #   if @message.from_desig == "Tenant"
    #     @house = House.find_by(tenant.id= from_id) 
    #   else
    #     @house = House.find(Tenant.find(@message.to_id).house_id)
    #   end
    # elsif @message.from_desig == "Security"
    #   @house = House.find(Security.find(@message.from_id).house_id)
    # elsif @message.from_desig == "Tenant"
    #   @house = House.find(Tenant.find(@message.from_id).house_id)
    # end
    @house = House.find(@message.house_id)
    @block = Block.find(@house.block_id)
    @apartment = Apartment.find(@block.apartment_id)
    @house_name = @apartment.name + ", Block : " + @block.name + ", Door no : " + @house.doorno
  end

  # GET /messages/new
  def new
    @message = Message.new
    @to_id = params[:id]
    if session[:desig] == "Owner"
      @from_id = Owner.find(session[:user]).name
      @to_id = Tenant.find(params[:to_id]).name
      @house_id = Tenant.find(params[:to_id]).house_id
    elsif session[:desig] == "Tenant"
      @from_id = Tenant.find(session[:user]).name
      if params[:desig] == "Tenant"
        @to_id = Tenant.find(params[:to_id]).name
        @house_id = Tenant.find(params[:to_id]).house_id
      else
        @to_id = Owner.find(params[:to_id]).name
        @house_id = Tenant.find(session[:user]).house_id
      end
    elsif session[:desig] == "Security"
      @from_id = Security.find(session[:user]).name
      @to_id = Tenant.find(params[:to_id]).name
      @house_id = Tenant.find(params[:to_id]).house_id
    end
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    debugger
    if params["message_type"] == "emergency"
      @house = Tenant.find(session[:user]).house_id
      @block = House.find(@house).block_id
      @apartment = Apartment.find(Block.find(@block).apartment_id)
      debugger
      @message = Message.new(from_id:params[:from_id], from_desig: "Tenant",to_id: @apartment.security.id, to_desig:"security", message:"Emergency!!!",status:false,message_type:"emergency", house_id:@house)
    else
      @message = Message.new(message_params)
    end
    

    respond_to do |format|
      if @message.save
        if session[:desig] == "Owner"
          format.html { redirect_to owner_path(@message.from_id), notice: "Message sent successfully " }
        elsif session[:desig] == "Tenant"
          format.html { redirect_to house_path(Tenant.find(@message.from_id).house_id), notice: "Message sent successfully"}
        elsif session[:desig] == "Security"
          format.html { redirect_to security_path(@message.from_id), notice: "Message sent successfully " }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy!

    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def approve
    @message = Message.find(params[:message_id])
    @message.status = true
    @message.save
    respond_to do |format|
    format.html { redirect_to house_url(params[:house_id]), notice: "Approved." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:to_id, :to_desig, :message, :image, :to, :house_id, :message_type).merge(from_id: session[:user], from_desig: session[:desig], status: false)
    end
end