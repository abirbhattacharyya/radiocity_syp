class Offer < ActiveRecord::Base
  attr_accessible :counter, :ip, :price, :product_id, :response, :token

  belongs_to :product
  has_one :payment, :dependent => :nullify

  scope :accepted_offers, {:conditions => ["response LIKE ? OR response LIKE ? OR response LIKE ?", "paid", "accepted", "counter"]}
  scope :paid_offers, {:conditions => ["response LIKE ?", "paid"]}
  scope :min_offers_of, lambda {|price| {:conditions => ["response LIKE ? and price <= ?", "paid", price]} }

  def accepted?
    (self.response.eql? "accepted")
  end

  def rejected?
    (self.response.eql? "rejected")
  end

  def paid?
    (self.response.eql? "paid")
  end

  def counter?
    (self.response.eql? "counter")
  end

  def last?
    (self.response.eql? "last")
  end
end
