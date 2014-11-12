class User < ActiveRecord::Base
  has_many :domains
  def password= pass
    self.salt = SecureRandom.base64 6
    super Digest::SHA2.base64digest "#{@salt}#{pass}#{@salt}"
    generate_passkey
  end

  def generate_passkey
    self.passkey = Digest::SHA2.base64digest SecureRandom.base64
  end

  def valid_user? pass
    np = Digest::SHA2.base64digest "#{@salt}#{pass}#{@salt}"
    return np == self.password
  end

  def self.authorize! passkey
    return nil if passkey.nil?
    self.where(:passkey => passkey).first
  end
end