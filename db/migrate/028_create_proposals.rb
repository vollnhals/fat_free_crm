class CreateProposals < ActiveRecord::Migration
  def self.up
    create_table :proposals do |t|
      t.string      :name,     :limit => 64, :null => false, :default => ""
      t.text        :description,     :limit => 255, :null => false, :default => ""
      t.date        :start_date
      t.date        :end_date
      t.datetime    :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :proposals
  end
end

