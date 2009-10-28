class ServicesController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  after_filter  :update_recently_viewed, :only => :show

  # GET /services
  # GET /services.xml
  def index
    @services = get_services(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @services }
    end
  end

  # GET /services/1
  # GET /services/1.xml
  def show
    @service = Service.my(@current_user).find(params[:id])
#    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = Service.new(:user => @current_user)
    @users = User.except(@current_user).all
    if params[:related]
      model, id = params[:related].split("_")
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @account }
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.my(@current_user).find(params[:id])
    @users = User.except(@current_user).all
    if params[:previous] =~ /(\d+)\z/
      @previous = Service.my(@current_user).find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @service
  end

  # POST /services
  # POST /services.xml
  def create
    @service = Service.new(params[:service])
    @users = User.except(@current_user).all

    respond_to do |format|
      if @service.save_with_permissions(params[:users])
        # None: account can only be created from the Accounts index page, so we 
        # don't have to check whether we're on the index page.
        @services = get_services
        format.js   # create.js.rjs
        format.xml  { render :xml => @service, :status => :created, :location => @service }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = Service.my(@current_user).find(params[:id])

    respond_to do |format|
      if @service.update_with_permissions(params[:service], params[:users])
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).all # Need it to redraw [Edit Account] form.
        format.js
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = Service.my(@current_user).find(params[:id])
    @service.destroy if @service

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

  # GET /services/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @services = get_services(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @service.to_xml }
    end
  end

  # POST /services/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by before_filter :auto_complete, :only => :auto_complete

  # GET /services/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel] == "true"
      @per_page = @current_user.pref[:services_per_page] || Service.per_page
      @outline  = @current_user.pref[:services_outline]  || Service.outline
      @sort_by  = @current_user.pref[:services_sort_by]  || Service.sort_by
      @sort_by  = Service::SORT_BY.invert[@sort_by]
    end
  end

  # POST /services/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:services_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:services_outline]  = params[:outline]  if params[:outline]
    @current_user.pref[:services_sort_by]  = Service::SORT_BY[params[:sort_by]] if params[:sort_by]
    @services = get_services(:page => 1)
    render :action => :index
  end

  private
  #----------------------------------------------------------------------------
  def get_services(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:services_sort_by] || Service.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:services_per_page]
    }

    # Call :get_services hook and return its output if any.
    services = hook(:get_services, self, :records => records, :pages => pages)
    return services.last unless services.empty?

    # Default processing if no :get_services hooks are present.
    if current_query.blank?
      Service.my(records)
    else
      Service.my(records).search(current_query)
    end.paginate(pages)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @services = get_services
      if @services.blank?
        @services = get_services(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = "#{@service.name} has beed deleted."
      redirect_to(services_path)
    end
  end
end
