class Profile < ActiveRecord::Base
  attr_accessible :address, :facebook_url, :email, :header_color, :name, :phone, :twitter, :website, :user_id, :website, :logo

  belongs_to :user

  has_attached_file :logo, {
    :path => ":rails_root/public/profiles/:id/logos/:style/:filename",
    :url => "/profiles/:id/logos/:style/:filename",
    :default_url => "/assets/mylogo.jpg"
    #, :styles => { :medium => "90x85>" }
  }
  validates_attachment :logo, :presence => {:message => "Hey, Upload a JPEG, GIF, or PNG image please!"},
    :content_type => { :content_type => ["image/jpg", "image/png", "image/gif", "image/bmp", "image/jpeg"] },
    :size => { :in => 0..5.megabytes }  
  
  validates_presence_of :name, :address, :phone, :website, :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "^Hey, incorrect email"
end
