class User < ActiveRecord::Base
  attr_accessible :password, :token, :username
  
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(token: random_token)
    end
  end

  validates_presence_of :password, :token, :username

end
