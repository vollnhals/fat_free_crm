class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
    t.string   "name",                                       :null => false
    t.decimal  "price", :precision => 19, :scale => 4
    t.string   "unit"
    t.string   "accounting_period"
    t.boolean  "vat",                     :default => true
    t.boolean  "active",                  :default => true
    t.boolean  "external",                :default => false
    t.boolean  "published",               :default => false
    t.integer  "minimum_term"
    t.integer  "term_of_notice"
    t.integer  "category_id"
    t.integer  "responsible_employee_id"
    t.integer  "assigned_employee_id"
    t.text     "description"
    t.timestamps
    end

  create_table "service_packages" do |t|
    t.integer  "packaged_service_id"
    t.integer  "service_id"
    t.integer  "count"
    t.timestamps
  end

  end

  def self.down
    drop_table :services
    drop_table :service_packages
  end
end
