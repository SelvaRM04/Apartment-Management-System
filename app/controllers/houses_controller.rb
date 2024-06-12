class HousesController < ApplicationController
  before_action :set_house, only: %i[ show edit update destroy ]

  # GET /houses or /houses.json
  def index
    @houses = House.all
  end

  # GET /houses/1 or /houses/1.json
  def show
    @messages_owner = []
    @messages_security = []
    @house.messages.each do |msg|
      if msg.from_desig == "Owner" || msg.to_desig == "owner"
        @messages_owner << msg
      elsif msg.from_desig == "Security" || msg.to_desig == "security"
        @messages_security << msg
      end
    end

    if session[:desig] == "Owner"
      @messages = @messages_owner
    elsif session[:desig] == "Security"
      @messages = @messages_security
    else
      @messages = @house.messages
    end
    @messages = @messages.reverse()
    debugger
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
    @existing_house = House.find_by(doorno:@house[:doorno])
    if @existing_house
      @existing_block = Block.find(@existing_house.block_id)
      if @existing_block.name == @house[:block]
        @existing_apartment = Apartment.find(@existing_block.apartment_id)
        if @existing_apartment.name == @house[:apartment]
          flag=1
          owner = 1 if @existing_house.owner_id == session[:user]
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
        format.html { redirect_to owner_url(@owner), notice: "House was successfully added." }
        format.json { render :show, status: :ok, location: @owner }
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
        if owner == 1
          format.html { redirect_to new_house_url(@owner), notice: "House already added to you." }
        else
          format.html { redirect_to new_house_url(@owner), notice: "House belongs to another owner." }
        end
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
    @house.destroy!

    respond_to do |format|
      format.html { redirect_to houses_url, notice: "House was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_house
      @house = House.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def house_params
      params.permit(:apartment, :block, :doorno)
    end
end
