class Payment < ActiveRecord::Base
  attr_accessible :city, :country, :email, :first_name, :last_name, :offer_id, :postal_code, :price, :quantity, :state, :street1, :street2, :transaction_id, :phone, :cc_type, :cc_number, :cc_expiry_m1, :cc_expiry_m2, :cc_expiry_y, :cvv

  belongs_to :offer
  validates :first_name,:presence => true
  validates :last_name,:presence => true
  validates :street1,:presence => true
  validates :city,:presence => true
  validates :state,:presence => true
  validates :country,:presence => true
  validates :postal_code,:presence => true

  validates_format_of :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "^Hey, please enter valid email"

  validate :valid_info
  attr_accessor :cc_expiry_m1, :cc_expiry_m2, :cvv, :payment_option

  Months = {
    "JANUARY" => 1,
    "FEBRUARY" => 2,
    "MARCH" => 3,
    "APRIL" => 4,
    "MAY" => 5,
    "JUNE" => 6,
    "JULY" => 7,
    "AUGUST" => 8,
    "SEPTEMBER" => 9,
    "OCTOBER" => 10,
    "NOVEMBER" => 11,
    "DECEMBER" => 12,
  }
  CARD_TYPES = [["Visa", "visa"], ["MasterCard", "master"], ["Discover", "discover"], ["American Express", "american_express"]]

  def self.month_options(from)
    options = Hash.new
    Months.each_key do |k|
      next if Months[k.to_s].to_i < from
      options[k.to_s]=Months[k.to_s]
    end
    return options.sort {|a,b| a[1]<=>b[1]}
  end

  def valid_info
    if self.transaction_id
      self.errors.add_to_base("Hey, transaction id can't be blank") if self.transaction_id.nil?
    end
  end

  def purchase(price)
    response = GATEWAY.purchase(price_in_cents(price), credit_card,purchase_options)
##    response = GATEWAY.purchase(price_in_cents(price), credit_card)
    if response.success?
  #     self.payment_type = TYPE[:credit_card]
  #     self.payment_status = STATUS[:success]
       self.transaction_id = response.params['transaction_id']
##       save
       [true,nil]
    else
      [false,response.message]
    end
  end

  def price_in_cents(price)
    price_in_dollar = price # * GBP_TO_USD
    (price_in_dollar*100).round
  end


 private

  def purchase_options
    {
      :ip => '127.0.0.1',
      :billing_address => {
        :name     =>  "%s %s" % [first_name, last_name],
        :address1 => street1,
        :city     => city,
        :state    => state,
        :country  => country,
        :zip      => postal_code
      }
    }
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.each do |error|
        field =
          if(error[0].downcase == "number")
            "Credit Card Number"
          elsif(error[0].downcase == "type")
            "Card Type"
          elsif(error[0].downcase == "verification_value")
            "Security Code"
          else
            error[0]
          end
        errors.add(field, error[1])
      end
    end
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => cc_type,
      :number             => cc_number,
      :verification_value => cvv,
      :month              => cc_expiry_m,
      :year               => cc_expiry_y,
      :first_name         => first_name,
      :last_name          => last_name
    )
  end

end
