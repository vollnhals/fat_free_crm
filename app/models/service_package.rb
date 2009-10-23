class ServicePackage < ActiveRecord::Base
  belongs_to :service
  belongs_to :packaged_service, :class_name => 'Service'

  validates_presence_of :service_id, :packaged_service_id  
  validates_presence_of :count, :packaged_service_name
#  validates_uniqueness_of :packaged_service_id, :scope => :service_id
  
  validate :correct_references

  def correct_references
      errors.add(:packaged_service_name, "must point to an existing service") if packaged_service_name && packaged_service.nil?
  end
  
  def packaged_service_name
  	self[:packaged_service_name] ||= packaged_service.try(:name)
  end
  
  def packaged_service_name=(name)
  	self[:packaged_service_name] = name
  	self.packaged_service = Service.find_by_name(name)
  end
end

