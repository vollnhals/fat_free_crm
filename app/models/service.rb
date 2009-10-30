class Service < ActiveRecord::Base
  enum_attr :unit, %w(piece hour)
  enum_attr :accounting_period, %w(once monthly yearly)

  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  has_many :service_packages, :dependent => :destroy
  has_many :packaged_services, :class_name => 'Service', :through => :service_packages
  has_many    :activities, :as => :subject, :order => 'created_at DESC'
  
  named_scope :created_by, lambda { |user| { :conditions => "user_id = #{user.id}" } }
  named_scope :assigned_to, lambda { |user| { :conditions => "assigned_to = #{user.id}" } }
		
  accepts_nested_attributes_for :service_packages, :allow_destroy => true, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

#	versioned
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :name, :price
  validates_format_of :price_before_type_cast, :with => /[,\.0-9]/, :message => I18n.t("price_not_valid")
  validates_uniqueness_of :name
  validate :users_for_shared_access

  SORT_BY = {
    "name"   => "services.first_name ASC",
    "date created" => "services.created_at DESC",
    "date updated" => "services.updated_at DESC"
  }

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                         ; end
  def self.outline  ;  "long"                     ; end
  def self.sort_by  ;  "services.created_at DESC" ; end


  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the account with.") if self[:access] == "Shared" && !self.permissions.any?
  end

end

