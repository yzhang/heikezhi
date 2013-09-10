class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates :name, :format => { :with => /\A[a-zA-Z0-9]+\z/, :message => I18n.t(:letters_and_numbers_only)}, :presence => true, :uniqueness => {:case_sensitive => false}

  has_many :articles
  has_one  :profile
  has_many :images

  delegate :twitter, :github, :google_plus, :bio, to: :profile

  before_create :setup_user
  before_create :generate_confirmation_token

  def avatar
    hash = Digest::MD5.hexdigest(email).to_s
    "http://www.gravatar.com/avatar/#{hash}"
  end

  def send_reset_password_instructions
    generate_reset_password_token! if should_generate_reset_token?
    DeviseMailer.reset_password_instructions(self).deliver
  end

  def atom_feed
    "/#{self.name.downcase}/atom"
  end
  
  def json_feed
    "/#{self.name.downcase}"
  end

  private
  def confirmation_required?
    false
  end

  def setup_user
    self.profile = Profile.new
  end
end
