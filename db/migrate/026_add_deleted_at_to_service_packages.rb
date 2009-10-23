class AddDeletedAtToServicePackages < ActiveRecord::Migration
  def self.up
    add_column :service_packages, :deleted_at, :datetime
  end

  def self.down
    remove_column :service_packages, :deleted_at
  end
end
