class AddNonFfcFieldsToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :abbreviation, :string, :default => "WEB"
    add_column :proposals, :state, :string, :default => "draft"
    add_column :proposals, :deadline, :date
    # references to other modules (account and contacts)
    add_column :proposals, :client_account_id, :integer
    add_column :proposals, :client_contact_id, :integer
    add_column :proposals, :client_technical_contact_id, :integer
    add_column :proposals, :employee_contact_id, :integer
    add_column :proposals, :employee_technical_contact_id, :integer
  end

  def self.down
    remove_column :proposals, :abbreviation, :string
    remove_column :proposals, :state, :string
    remove_column :proposals, :deadline, :date

    remove_column :proposals, :client_account_id, :integer
    remove_column :proposals, :client_contact_id, :integer
    remove_column :proposals, :client_technical_contact_id, :integer
    remove_column :proposals, :employee_contact_id, :integer
    remove_column :proposals, :employee_technical_contact_id, :integer
  end
end
