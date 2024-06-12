class OwnersController < ApplicationController
  before_action :set_owner, only: %i[ edit update destroy ]

  # GET /owners or /owners.json
  def index
    @owners = Owner.all
    if session[:desig] != "Admin"
      respond_to do |format|
       format.html { redirect_to owner_path(session[:user])} 
       format.json { head :no_content } 
      end
    end 
  end

  # GET /owners/1 or /owners/1.json
  def show
    @messages = Message.where(from_id: session[:user]).or(Message.where(to_id: session[:user])).order(created_at: :desc)
    @messages_unread_count = 0
    @messages.each do |message|
      if message.status == false
        @messages_unread_count+=1
      end
    end
    @owner = Owner.find(params[:id])
    @houses = House.all
    debugger
  end

  # GET /owners/new
  def new
    @owner = Owner.new
  end

  # GET /owners/1/edit
  def edit
  end

  # POST /owners or /owners.json
  def create
    @owner = Owner.new(owner_params)
    
    respond_to do |format|
      if @owner.save
        session[:user] = @owner.id
        session[:desig] = "Owner"
        format.html { redirect_to owner_url(@owner), notice: "Owner was successfully created." }
        format.json { render :show, status: :created, location: @owner }
      else
        # format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @owner.errors, status: :unprocessable_entity }
        format.html { redirect_to new_owner_path, notice: @owner.errors.full_messages }
      end
    end
  end

  # PATCH/PUT /owners/1 or /owners/1.json
  def update
    respond_to do |format|
      if @owner.update(owner_params)
        format.html { redirect_to owner_url(@owner), notice: "Owner was successfully updated." }
        format.json { render :show, status: :ok, location: @owner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @owner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /owners/1 or /owners/1.json
  def destroy
    @owner.destroy!

    respond_to do |format|
      format.html { redirect_to owners_url, notice: "Owner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_house
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_owner
      @owner = Owner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def owner_params
      params.require(:owner).permit(:name, :email, :password)
    end

    def house_params
      params.permit(:apartment, :block, :doorno)
    end
end
