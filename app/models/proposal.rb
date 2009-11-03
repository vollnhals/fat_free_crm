# t.string :name,     :limit => 64, :null => false, :default => ""
# t.text        :description,     :limit => 255, :null => false, :default => ""
# t.date        :start_date
# t.date        :end_date
# t.datetime    :deleted_at
# :access, :string, :limit => 8, :default => "Private"
# :user_id, :integer
# :assigned_to, :integer
#
class Proposal < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many :tasks, :as => :asset, :dependent => :destroy, :order => 'created_at DESC'
  has_many    :activities, :as => :subject, :order => 'created_at DESC'

  named_scope :created_by, lambda { |user| { :conditions => "user_id = #{user.id}" } }
  named_scope :assigned_to, lambda { |user| { :conditions => "assigned_to = #{user.id}" } }

  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  versioned
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
