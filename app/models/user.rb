class User < ActiveRecord::Base
	#before_save {self.email = email.downcase}
	attr_accessor :remember_token, :activation_token, :reset_token
	before_create :create_activation_digest
	has_many :microposts, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	has_many :comments, dependent: :delete_all

	has_many :reverse_relationships, foreign_key: "followed_id",
									 class_name: "Relationship",
									 dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower

	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	before_save { email.downcase! }
	validates :password, length: {minimum: 6}
	
	

	def feed 
	  Micropost.from_users_followed_by(self)
	end

	def following?(other_user)
	  relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
	  relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
	  relationships.find_by(followed_id: other_user.id).destroy!
	end

	def User.new_remember_token
	  SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
	  Digest::SHA1.hexdigest(token.to_s)
	end

	#Returns the hash digest of the given string
	def User.digest(string)
	  cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
	  												BCrypt::Engine.cost
	  BCrypt::Password.create(string, cost: cost)
	end

	def User.new_token
	  SecureRandom.urlsafe_base64
	end

	#Remembers a user in the database for use in persistent sessions.
	def remember
	  self.remember_token = User.new_token
	  update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
	  digest = send("#{attribute}_digest")
	  return false if digest.nil?
	  BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
	  update_attribute(:remember_digest, nil)
	end

	#Activate an account
	def activate
	  update_attribute(:activated, true)
	  update_attribute(:activated_at, Time.zone.now)
	end

	#Sends activation email
	def send_activation_email
	  UserMailer.account_activation(self).deliver
	end

	#Sets the password reset attributes
	def create_reset_digest
	  self.reset_token = User.new_token
	  update_attribute(:reset_digest, User.digest(reset_token))
	  update_attribute(:reset_sent_at, Time.zone.now)
	end

	#Sends password reset email
	def send_password_reset_email
	  UserMailer.password_reset(self).deliver
	end

	def password_reset_expired?
	  reset_sent_at < 2.hours.ago
	end

	private
    	def create_remember_token
    	  self.remember_token = User.encrypt(User.new_remember_token)
    	end

    	def create_activation_digest
    	  self.activation_token = User.new_token
    	  self.activation_digest = User.digest(activation_token)
    	end
end
