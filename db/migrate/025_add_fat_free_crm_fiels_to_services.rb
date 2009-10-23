class AddFatFreeCrmFielsToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :user_id, :integer
    add_column :services, :assigned_to, :integer
    add_column :services, :deleted_at, :datetime

    add_index :services, [ :user_id, :name, :deleted_at ], :unique => true
    add_index :services, :assigned_to
  end

  def self.down
    remove_column :services, :user_id, :integer
    remove_column :services, :assigned_to, :integer
    remove_column :services, :deleted_at, :datetime

    remove_index :services, [ :user_id, :name, :deleted_at ]
    remove_index :services, :assigned_to
  end
end
