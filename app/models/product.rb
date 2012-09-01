class Product < ActiveRecord::Base
  attr_accessible :description, :is_live, :name, :quantity, :regular_price, :target_price, :user_id, :image, :image_remote_url, :product_type
  attr_accessor :image_remote_url

  TYPES = {
    :ticket=> 1,
    :package => 2    
  }

  scope :by_product_type, lambda{|type| {:conditions => ["product_type = ?", type] } }

  belongs_to :user
  has_many :offers, :dependent => :destroy
  has_many :payments, :through => :offers

  has_attached_file :image, {
    :path => ":rails_root/public/products/:id/:style/image/:filename",
    :url => "/products/:id/:style/image/:filename",
    :default_url => "/assets/mylogo.jpg", 
    :styles => { :medium => "90x85>" }
  }
  validates_attachment :image, :content_type => {:message => "Hey, Upload a JPEG, GIF, or PNG image please!", :content_type => ["image/jpg", "image/png", "image/gif", "image/bmp", "image/jpeg"] },
    :size => { :in => 0..5.megabytes }

  
  validates :name, :presence => {:message => "Hey, name can't be blank"}
  # validates :author, :presence => {:message => "Hey, author can't be blank"}
  validates :description, :presence => {:message => "Hey, description can't be blank"}
  validates :regular_price, :presence => {:message => "Hey, price can't be blank"}
  validates :target_price, :presence => {:message => "Hey, minimum price can't be blank"}
  validates :image, :presence => {:message => "Hey, image can't be blank"}

  validates_uniqueness_of :name, :scope => [:user_id, :regular_price, :is_live], :message => "Hey, name already been taken"

  validate :valid_price?

  before_validation :download_remote_image, :if => :image_url_provided?


  def self.get_ticket_prodcut_names
    names = Product.by_product_type(Product::TYPES[:ticket]).map(&:name)
    names.uniq!
    names.sort!
    return names
  end


  def is_ticket?
    return self.product_type == TYPES[:ticket]
  end

  def is_package?
    return self.product_type == TYPES[:package]
  end

  def color
    self.color_description.gsub(/\d+/, '').strip
  end

  def reg_price(no_of_tickets=1)
    no_of_tickets = 1 if no_of_tickets.blank?
    return(self.regular_price * no_of_tickets.to_i)
  end

  def floor_price(no_of_tickets=1)
    no_of_tickets = 1 if no_of_tickets.blank?
    return(self.target_price * no_of_tickets.to_i)
  end

  def min_price(no_of_tickets=1)
    no_of_tickets = 1 if no_of_tickets.blank?
    (self.regular_price.to_f * 0.30 * no_of_tickets.to_i)
  end

  def sold_qty
    return self.payments.map{|p| p.quantity}.sum
  end

  def stock_available?
    return true if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    stock > 0 ? true : false
  end

  def stock_available
    return "Unlimited" if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    return stock
  end

  private
  def valid_price?
    if self.regular_price and self.target_price
      self.errors.add(:quantity, "Hey, quantity should be greater than 0") if self.quantity and self.quantity <= 0
      self.errors.add(:regular_price, "Hey, price should be greater than 0") if self.regular_price <= 0 or self.target_price <= 0
      self.errors.add(:target_price, "Hey, target price should be less than regular price") if self.regular_price < self.target_price
    end
  end

  def image_url_provided?
    (!self.image_remote_url.blank? || !self.image_remote_url.blank?)
  end

  def download_remote_image
    self.image = do_download_remote_image(image_remote_url) if !self.image_remote_url.blank?
    #self.image_remote_url = image_url
  end

  def do_download_remote_image(url)
    io = open(url)
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  #rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    
  end
end
