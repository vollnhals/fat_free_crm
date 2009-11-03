class ProposalsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab, :only => [ :index, :show ]
  before_filter :auto_complete, :only => :auto_complete
  after_filter  :update_recently_viewed, :only => :show

  # GET /proposals
  # GET /proposals.xml
  def index
    @proposals = get_proposals(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @proposals }
    end
  end

  # POST /proposals
  # POST /proposals.xml
  def create
    @proposal = Proposal.new(params[:proposal])
    @users = User.except(@current_user).all

    respond_to do |format|
      if @proposal.save_with_permissions(params[:users])
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @proposals = get_proposals
        format.js   # create.js.rjs
        format.xml  { render :xml => @proposal, :status => :created, :location => @proposal }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @proposal.errors, :status => :unprocessable_entity }
      end
    end
  end

    # GET /proposals/1
  # GET /proposals/1.xml
  def show
    @proposal = Proposal.my(@current_user).find(params[:id])
#    @stage = Setting.as_hash(:opportunity_stage)
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @proposal }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end

  # GET /proposals/new
  # GET /proposals/new.xml
  def new
    @proposal = Proposal.new(:user => @current_user)
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

  # GET /proposals/1/edit
  def edit
    @proposal = Proposal.my(@current_user).find(params[:id])
    @users = User.except(@current_user).all
    if params[:previous] =~ /(\d+)\z/
      @previous = Proposal.my(@current_user).find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @proposal
  end

  private
  #----------------------------------------------------------------------------
  def get_proposals(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]

    records = {
      :user => @current_user,
      :order => @current_user.pref[:proposals_sort_by] || Proposal.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:proposal_per_page]
    }

    # Call :get_proposals hook and return its output if any.
    proposals = hook(:get_proposals, self, :records => records, :pages => pages)
    return proposals.last unless proposals.empty?

    # Default processing if no :get_proposals hooks are present.
    if current_query.blank?
      Proposal.my(records)
    else
      Proposal.my(records).search(current_query)
    end.paginate(pages)
  end

  # GET /proposals/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel] == "true"
      @per_page = @current_user.pref[:proposals_per_page] || Proposal.per_page
      @outline  = @current_user.pref[:proposals_outline]  || Proposal.outline
      @sort_by  = @current_user.pref[:proposals_sort_by]  || Proposal.sort_by
      @sort_by  = Proposal::SORT_BY.invert[@sort_by]
    end
  end
end
