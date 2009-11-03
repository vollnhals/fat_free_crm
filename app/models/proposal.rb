# t.string :name,     :limit => 64, :null => false, :default => ""
# t.text        :description,     :limit => 255, :null => false, :default => ""
# t.date        :start_date
# t.date        :end_date
# t.datetime    :deleted_at
# :access, :string, :limit => 8, :default => "Private"
# :user_id, :integer
# :assigned_to, :integer
#    add_column :proposals, :abbreviation, :string, :default => "WEB"
#    add_column :proposals, :state, :string, :default => "draft"
#    add_column :proposals, :deadline, :date
#    add_column :proposals, :client_account_id, :integer
#    add_column :proposals, :client_contact_id, :integer
#    add_column :proposals, :client_technical_contact_id, :integer
#    add_column :proposals, :employee_contact_id, :integer
#    add_column :proposals, :employee_technical_contact_id, :integer
#
class Proposal < ActiveRecord::Base
  enum_attr :abbreviation, %w(WEB FS LVN) 

  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to

  belongs_to  :client_account, :class_name => "Account"
  belongs_to  :client_contact, :class_name => "Contact"
  belongs_to  :client_technical_contact, :class_name => "Contact"
  # TODO when we have an employees module we should link proposals to employees instead of contacts. we assume that contacts are persons not working in the crm organisation but in other companies (clients).
  belongs_to  :employee_contact, :class_name => "Contact"
  belongs_to  :employee_technical_contact, :class_name => "Contact"

  has_many    :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  has_many    :activities, :as => :subject, :order => 'created_at DESC'

  named_scope :created_by, lambda { |user| { :conditions => "user_id = #{user.id}" } }
  named_scope :assigned_to, lambda { |user| { :conditions => "assigned_to = #{user.id}" } }

  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  # versioning plugin not installed properly -> disable versioning 
  #versioned
  uses_user_permissions
  acts_as_commentable
  acts_as_paranoid

  validates_presence_of :name
  validates_uniqueness_of :name
  validate :users_for_shared_access

  SORT_BY = {
    "name"   => "proposals.name ASC",
    "date created" => "proposals.created_at DESC",
    "date updated" => "proposals.updated_at DESC"
  }

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ;  20                          ; end
  def self.outline  ;  "long"                      ; end
  def self.sort_by  ;  "proposals.created_at DESC" ; end


  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, "^Please specify users to share the account with.") if self[:access] == "Shared" && !self.permissions.any?
  end
end
