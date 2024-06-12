class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[ show edit update destroy ]

  # GET /tenants or /tenants.json
  def index
    @tenants = Tenant.all
  end

  # GET /tenants/1 or /tenants/1.json
  def show
    @messages = Message.order("created_at DESC").where(from_id: session[:user]).or(Message.where(to_id: session[:user]))
    debugger
  end

  # GET /tenants/new
  def new
  end

  def blocks
    @blocks = Block.where(apartment_id: params[:apartment_id])
    render json: @blocks
  end

  # GET /tenants/1/edit
  def edit
  end

  # POST /tenants or /tenants.json
  def create
    debugger
    respond_to do |format|
      @apartment = Apartment.find(params["apartment"]).blocks
      @ap = Block.where(name:params["block"], apartment_id: params["apartment"])
      if @ap.length !=0
        @ap.each do |block|
          @h = House.where(doorno: params["doorno"],block_id: block.id)
          @h = @h[0]
          debugger
          if @h && @h.tenant == nil
            @tenant = Tenant.new(tenant_params)
            @h.tenant = @tenant
            debugger
            if @h.save
              session[:user] = @tenant.id
              session[:desig] = "Tenant"
              format.html { redirect_to tenant_url(@tenant), notice: "Tenant was successfully created." }
              format.json { render :show, status: :created, location: @tenant }
            else
              format.html { redirect_to new_tenant_path, notice: "Invalid! Try again" }
            end
          else
            format.html { redirect_to new_tenant_path, notice: "Invalid! House is occupied" }
          end
        
        end
      end
      debugger

    format.html { render :new, status: :unprocessable_entity }
    format.json { render json: @tenant.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /tenants/1 or /tenants/1.json
  def update
    respond_to do |format|
      if @tenant.update(tenant_params)
        format.html { redirect_to tenant_url(@tenant), notice: "Tenant was successfully updated." }
        format.json { render :show, status: :ok, location: @tenant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tenants/1 or /tenants/1.json
  def destroy
    @tenant.destroy!

    respond_to do |format|
      format.html { redirect_to tenants_url, notice: "Tenant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenant
      @tenant = Tenant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tenant_params
      params.permit(:name, :email, :password)
    end
end
