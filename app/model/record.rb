require 'resolv'
class Record < ActiveRecord::Base
  belongs_to :domain
  before_save :update_soa
  validates :name, exclusion: { in: [nil] }
  validates :content, presence: true
  validates :ttl, numericality: true
  def self.types
    %w(A AAAA CNAME MX TXT SRV NS SOA)
  end
  validates :type, inclusion: { in: types }

  def prefix= prefix
    if prefix.blank?
      self.name = self.domain.name
    else
      self.name = prefix + '.' + self.domain.name
    end
  end
  def as_json(options = {})
    super(options.merge(:methods => :type))
  end
  def update_soa
    return if self.is_a? SOA
    return if !changed?
    self.domain.update_soa
  end
end

class A < Record
  validates_format_of :content, :with => Resolv::IPv4::Regex
end
class AAAA < Record
  validates_format_of :content, :with => Resolv::IPv6::Regex
end
class CNAME < Record
  validates_format_of :content, :with => /\A[a-zA-Z0-9\-\.]+\.[a-zA-Z]+\z/
end
class MX < Record
end
class TXT < Record
end
class SRV < Record
end
class NS < Record
  before_save { self.name = self.domain.name }
end
class SOA < Record
  before_save { self.name = self.domain.name }
end
