class SitesController < ApplicationController
  
  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}
  
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all
    @instruments = Instrument.all
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @instruments = Instrument.all.where("site_id = ?", params[:id])
    @site = Site.find(params[:id])
  end

  # GET /sites/new
  def new
    @site = Site.new
    
    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @site
    end
    
  end

  # GET /sites/1/edit
  def edit
    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @site
    end    
  end
  
  # GET /sites/geo
  def geo
    @sites = Site.all

    if @profile.secure_data_viewing
      if @sites.count > 0
        authorize! :view, @sites[0]
      end
    end    

    @site_markers = Gmaps4rails.build_markers(@sites) do |site, marker|
      marker.infowindow(ActionController::Base.helpers.link_to(site.name ||= 'Name?',site_path(site)).html_safe)
      marker.lat site.lat
      marker.lng site.lon
      marker.title site.name
    end
  end
  
  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(site_params)

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @site
    end

    respond_to do |format|
      if @site.save
        format.html { redirect_to '/sites', notice: 'Site was successfully created.' }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    
    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @site
    end
    
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @site
    end
    
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, :lat, :lon, :elevation, :description)
    end
end