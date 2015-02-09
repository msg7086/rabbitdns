class Domain < ActiveRecord::Base
  has_many :records
  belongs_to :user
  def self.inheritance_column
    'nothing'
  end
  def create_name_servers
    self.records.where(type: 'NS').destroy_all
    $config['name_servers'].each do |ns|
      self.records.create type: 'NS', name: '', content: ns, ttl: 43200
    end
  end
  def update_soa
    soa = self.records.find_by_type 'SOA'
    if soa.nil?
      soa = self.records.create type: 'SOA', name: self.name, content: '-', ttl: 43200
    end
    ns = $config['name_servers'].first
    soa.content = "#{self.name} #{ns} #{Time.now.to_i} 3600 360 1209600 300"
    soa.save
  end
end