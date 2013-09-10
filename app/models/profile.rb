class Profile < ActiveRecord::Base

  SOCIALS = [:twitter, :github, :google_plus]

  validates :bio, length: {maximum: 140}

  validates :twitter, :format => {:with => URI::regexp, :message => 'Invalid URL', :allow_blank => true}
  validates :github, :format => {:with => URI::regexp, :message => 'Invalid URL', :allow_blank => true}
  validates :google_plus, :format => {:with => URI::regexp, :message => 'Invalid URL', :allow_blank => true}
end