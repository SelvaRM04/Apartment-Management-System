class MessagesController < ApplicationController
  
  before_action :require_user
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Message.where(from_id: session[:user]).or(Message.where(to_id: session[:user])).order(created_at: :desc)
    @image_show = false
    flash[:alert] = "Unauthorized request"
      redirect_to "/home"
  end

  # GET /messages/1 or /messages/1.json
  def show
    if @message.to_id == session[:user] || @message.from_id == session[:user]
      @image_show = true
      if @message.message_type != "approval" && @message.from_desig != session[:desig]
        @message.status = true;
      end
      @message.save
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
      
    else
      flash[:alert] = "Unauthorized request"  
      redirect_to "/home"
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
    @to_id = params[:id]
    if session[:desig] == "Owner"
      begin
        @from_id = Owner.find(session[:user]).name
        @to_id = Tenant.find(params[:to_id]).name
        @house_id = Tenant.find(params[:to_id]).house_id
      rescue ActiveRecord::RecordNotFound => e
        redirect_to '/home'
      end
      
    elsif session[:desig] == "Tenant"
      begin
        @from_id = Tenant.find(session[:user]).name
        if params[:desig] == "Tenant"
          @to_id = Tenant.find(params[:to_id]).name
          @house_id = Tenant.find(params[:to_id]).house_id
        
        else
          @to_id = Owner.find(params[:to_id]).name
          @house_id = Tenant.find(session[:user]).house_id
        end
      rescue ActiveRecord::RecordNotFound => e
        redirect_to '/home'
      end
    elsif session[:desig] == "Security"
      begin
        @from_id = Security.find(session[:user]).name
        @to_id = Tenant.find(params[:to_id]).name
        @house_id = Tenant.find(params[:to_id]).house_id
      rescue ActiveRecord::RecordNotFound => e
        redirect_to '/home'
      end
    end
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    # debugger
    respond_to do |format|
      if params["message_type"] == "emergency"
        @house = Tenant.find(session[:user]).house_id
        @block = House.find(@house).block_id
        @apartment = Apartment.find(Block.find(@block).apartment_id)
        # debugger
        if @apartment.security == nil
          format.html { redirect_to house_url(@house), notice: "Security not assigned! Contact neighbours  " }
        else
        @message = Message.new(from_id:session[:user], from_desig: "Tenant",to_id: @apartment.security.id, to_desig:"security", message:"Emergency!!!",status:false,message_type:"emergency", house_id:@house)
        end
      else
        @message = Message.new(message_params)
      end
      
      if @message
        if @message.to_desig == "tenant"
          begin
            @user = Tenant.find(@message.to_id)
          rescue ActiveRecord::RecordNotFound => e
            redirect_to '/home'
          end
        elsif @message.to_desig == "owner"
          begin
              @user = Owner.find(@message.to_id)
            rescue ActiveRecord::RecordNotFound => e
              redirect_to '/home'
            end
        elsif @message.to_desig == "security"
          begin
              @user = Security.find(@message.to_id)
            rescue ActiveRecord::RecordNotFound => e
              redirect_to '/home'
            end
        end
      end
      if @user!=nil
        if @message && @message.save
          format.html { redirect_to "/home", notice: "Message sent successfully " }
        else
          format.html { redirect_to "/home", alert: "Message not sent " }
        end
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
      if @message.message_type == "approval"
        flash[:notice] = "Approved." 
      end
     redirect_to house_url(params[:house_id])
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
