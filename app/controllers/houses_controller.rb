class HousesController < ApplicationController
  before_action :require_user
  before_action :set_house, only: %i[ show edit update destroy ]

  # GET /houses or /houses.json
  def index
    @houses = House.all
  end

  # GET /houses/1 or /houses/1.json
  def show
    if session[:desig] == "Owner"
      if @house.owner_id != session[:user]
        flash[:alert] = "Unauthorized request"
        redirect_to "/home", :id => session[:user]
      else
        @messages_owner = []
        @house.messages.each do |msg|
          if msg.from_desig == "Owner" || msg.to_desig == "owner"
            @messages_owner << msg
          end
        end
        @messages = @messages_owner
      end

    elsif session[:desig] == "Security"
      @security = Apartment.find(Block.find(House.find(@house.id).block_id).apartment_id).security
      @security = @security.id if @security
      if !@security || @security != session[:user]
        flash[:alert] = "Unauthorized request"
        redirect_to "/home", :id => session[:user]
      else
        @messages_security = []
        @house.messages.each do |msg|
          if msg.from_desig == "Security" || msg.to_desig == "security"
            @messages_security << msg
          end
        end
        @messages = @messages_security
      end

    elsif session[:desig] == "Tenant"
      @messages = @house.messages
      if params[:id]
        @house = House.find(params[:id])
        if !@house.tenant || @house.tenant.id != session[:user]
          flash[:alert] = "Invalid request"
        end
        redirect_to "/home", :id => session[:user]
      end
    
    else
    end

    if @messages
      @messages = @messages.reverse()
    end 
  end

  # GET /houses/new
  def new
    @house = House.new
  end

  # GET /houses/1/edit
  def edit
  end

  # POST /houses or /houses.json
  def create
    flag=0
    owner=0
    @house = house_params
    @existing_houses = House.where(doorno:@house[:doorno])
    if @existing_houses
      @existing_blocks = []
      @existing_houses.each do |house|
        block = Block.find(house.block_id)
        if block.name == @house[:block]
          @existing_blocks << block
        end
      end

      if @existing_blocks.length > 0
        @existing_blocks.each do |block|
          apartment = Apartment.find(block.apartment_id)
          if apartment.name == @house[:apartment]
            flag = 1
          end
        end
      end
    end

    respond_to do |format|

      if flag==0
        house = House.new(doorno: @house[:doorno])
        
        blockname = nil
        apartment = Apartment.find_by(name: @house[:apartment])
        if apartment==nil
          apartment = Apartment.new(name: @house[:apartment])
        else
          apartment.blocks.each do |block|
            if block.name == @house[:block]
              blockname = block
              break
            end
          end
        end
        if blockname == nil
          blockname = Block.new(name: @house[:block])
        end
          blockname.houses << house
        apartment.blocks << blockname
        apartment.save
        @owner = Owner.find(session[:user])
        @owner.houses << house
        @owner.save
        format.html { redirect_to "/home", notice: "House was successfully added." }
        
      # else
      #   flash[:alert] = ["House belongs to another owner"]
      #   redirect_to :new_house_path
      # else
      #   flash[:notice] = "House belongs to another owner"
      #   format.html { redirect_to new_house_path, status: :unprocessable_entity }
      #   format.json { render json: flash[:notice], status: :unprocessable_entity }
      # end
      else
        #   flash[:notice] = "House belongs to another owner"
        # format.html { render new_house_path, status: :unprocessable_entity, notice: "House belongs to another owner" }
        
          format.html { redirect_to new_house_url(@owner), alert: "House already exists." }
      
      end
    end
  end

  # PATCH/PUT /houses/1 or /houses/1.json
  def update
    respond_to do |format|
      if @house.update(house_params)
        format.html { redirect_to house_url(@house), notice: "House was successfully updated." }
        format.json { render :show, status: :ok, location: @house }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @house.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /houses/1 or /houses/1.json
  def destroy
    # debugger
    @house.destroy!

    respond_to do |format|
      format.html { redirect_to root_path, notice: "House was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_house
      if params[:id]
        @house = House.find(params[:id])
      elsif session[:desig] == "Tenant"
        @house = House.find(Tenant.find(session[:user]).house_id)
      end

    end

    # Only allow a list of trusted parameters through.
    def house_params
      params.permit(:apartment, :block, :doorno)
    end
end
