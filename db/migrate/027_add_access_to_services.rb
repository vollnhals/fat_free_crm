class AddAccessToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :access, :string, :limit => 8, :default => "Private"
  end

  def self.down
    remove_column :services, :access
  end
end
