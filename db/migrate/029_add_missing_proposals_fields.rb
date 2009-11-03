class AddMissingProposalsFields < ActiveRecord::Migration
  def self.up
    add_column :proposals, :access, :string, :limit => 8, :default => "Private"
    add_column :proposals, :user_id, :integer
    add_column :proposals, :assigned_to, :integer
  end

  def self.down
    remove_column :proposals, :access, :string
    remove_column :proposals, :user_id, :integer
    remove_column :proposals, :assigned_to, :integer
  end
end
