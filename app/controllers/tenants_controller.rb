class TenantsController < ApplicationController

  before_action :require_user, except: [ :new, :create ]
  before_action :set_tenant, only: %i[ show edit update destroy ]

  # GET /tenants or /tenants.json
  def index
    @tenants = Tenant.all
    if session[:desig] != "Admin"
      respond_to do |format|
        flash[:alert] = "Invalid request"
        format.html { redirect_to "/home"} 
        format.json { head :no_content } 
      end
    end 
  end

  # GET /tenants/1 or /tenants/1.json
  def show
    if params[:id]
      if params[:id].to_i != session[:user] || session[:desig] != "Tenant"
        flash[:alert] = "Invalid request"
      end
      redirect_to "/home", :id => session[:user]
    else
      @messages = Message.order("created_at DESC").where(from_id: session[:user]).or(Message.where(to_id: session[:user]))
    end
    #  # debugger
  end

  # GET /tenants/new
  def new
    if params[:tenant] != nil
      @tenant = Tenant.new(email:params[:tenant][:email], name:params[:tenant][:name], password:params[:tenant][:password])
    else
      @tenant = Tenant.new
    end
  end

  # def blocks
  #   @blocks = Block.where(apartment_id: params[:apartment_id])
  #   render json: @blocks
  # end

  # GET /tenants/1/edit
  def edit
    if params[:id] && session[:desig] == "Tenant"
      if params[:id].to_i != session[:user]
        flash[:alert] = "Invalid request"
        redirect_to "/home", :id => session[:user]
      else
        redirect_to "/edit"
      end
    end
  end

  # POST /tenants or /tenants.json
  def create
    respond_to do |format|

      @tenant = Tenant.new(tenant_params)
      @apartment = Apartment.find(params[:tenant]["apartment"]).blocks
      @ap = Block.where(name:params[:tenant]["block"], apartment_id: params[:tenant]["apartment"])
      if @ap.length !=0
        @ap.each do |block|
          @h = House.where(doorno: params[:tenant]["doorno"],block_id: block.id)
          @h = @h[0]
          #  # debugger
          
          if @h && @h.tenant == nil
            if Tenant.find_by(name:@tenant.name) != nil
              format.html { redirect_to new_tenant_path, alert: "Name has already taken" }
            elsif Tenant.find_by(email: @tenant.email) != nil
              format.html { redirect_to new_tenant_path, alert: "Email has already taken" }
            else
             # debugger
            #  # debugger
              @h.tenant = @tenant
              if @h.save
                session[:user] = @h.tenant.id
                session[:desig] = "Tenant"
                debugger
                format.html { redirect_to "/home", notice: "Tenant was successfully created." }
              else
                format.html { redirect_to new_tenant_path, alert: "Invalid! Try again" }
              end
            end
          else
            format.html { redirect_to new_tenant_path, alert: "Invalid! House is occupied already" }
          end
        
        end
      else
        format.html { redirect_to new_tenant_path, alert: "Invalid! House doesn\'t exist" }
      end
      #  # debugger

    format.html { render :new, status: :unprocessable_entity }
    format.json { render json: @tenant.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /tenants/1 or /tenants/1.json
  def update
    respond_to do |format|
      @updated_values = edit_params
      if @updated_values[:password]!="" && @updated_values[:new_password]!=""
        if @tenant.authenticate(@updated_values[:password])
          if @tenant.update(name: @updated_values[:name],email: @updated_values[:email],password: @updated_values[:new_password])
            format.html { redirect_to "/home", notice: "Tenant was successfully updated." }
          else
            format.html { redirect_to edit_tenant_path(@tenant), alert: @owner.errors.full_messages[0] }
          end
        else
          format.html { redirect_to "/edit", alert: "Incorrect Password entered" }
        end
      else
        if @tenant.update(name: @updated_values[:name],email: @updated_values[:email])
          format.html { redirect_to "/home", notice: "Tenant was successfully updated." }
        else
          format.html { redirect_to "/edit", alert: @owner.errors.full_messages[0] }
        end
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
      if params[:id]
        @tenant = Tenant.find(params[:id])
      else
        @tenant = Tenant.find(session[:user])
      end
    end

    # Only allow a list of trusted parameters through.
    def tenant_params
      params.require(:tenant).permit(:name, :email, :password)
    end

    def edit_params
      params.require(:tenant).permit(:name, :email, :password, :new_password)
    end
end
