class ProductsController < ApplicationController
  before_filter :check_login, :except => [:show, :payments, :download_pdf]

  def index
    @products = current_user.products
  end
  
  def edit
    @product = Product.find_by_id(params[:id])
    render :action => :update
  end

  def update    
    id = params[:id]
    redirect_to "/" and return if id.nil?
    @product = Product.find_by_id(id)
    redirect_to "/" and return if @product.nil?
    #if request.post?
      @product.attributes = params[:product]
      if @product.save
        redirect_to :action => :index
      else
        flash[:error] = @product.errors.first[1]
      end
    #end
  end

  def create
    if request.post?
      @product = current_user.products.new(params[:product])
      if @product.valid? and @product.errors.empty?
        @product.quantity = params[:product][:quantity].gsub(/\D+/, "") if params[:product][:quantity]
        @product.regular_price = params[:product][:regular_price].gsub(/\D+/, "")
        @product.target_price = params[:product][:target_price].gsub(/\D+/, "")
        if @product.save
          @product = nil
          flash[:notice] = "Yeah, product added, cool!"
          if params[:submit_button].strip.downcase.eql? "finish"
            redirect_to root_path
    	  else
          	redirect_to :action => :new
          end
        else
          flash[:error] = @product.errors.first[1]
          redirect_to :action => :new
        end
      else
        flash[:error] = @product.errors.first[1]
          redirect_to :action => :new
      end
    end
  end

  def payments
    if request.post?
      if params[:email]
        @payment = Payment.find(params[:id])
        @email = params[:email]
        if check_emails(@email)
          NotifyMailer.sendcoupon(@email, @payment).deliver
          flash[:notice] = "Thank you for playing! You will get your voucher soon!"
          redirect_to root_path
          return
        else
          flash[:error]= "Hi, please enter a valid email address"
          render :template => "/products/success"
          return
        end
      else
        @offer = Offer.find_by_id(params[:id].to_i)
        if @offer.nil?
          redirect_to root_path
          return
        end
      end
      @month = Date.today.month
      @dates = session[@offer.product_id.to_s]
      if params[:payment]
          @payment = Payment.new(params[:payment])    
          @payment.quantity = session[:no_of_tickets]      
          @payment.offer = @offer
          @payment.cc_expiry_m = (@payment.cc_expiry_y == Date.today.year) ? @payment.cc_expiry_m1 : @payment.cc_expiry_m2
          @month = @payment.cc_expiry_m
          if @payment.valid?
            success,msg = @payment.purchase(@payment.price)
            if success
              @payment.cc_number = @payment.cc_number + 42891
              payment_found = Payment.find_by_offer_id(@offer.id)
              if payment_found
                @payment = payment_found
              else
                @payment.save
                admins = "dhaval.parikh33@gmail.com, mailtoankitparekh@gmail.com, brijeshshah86@gmail.com"
                if Rails.env == "development"
                  recipients = admins
                else
                  recipients = @payment.email
                end
                # NotifyMailer.payment_mail_to_merchant(recipients, @payment).deliver
                # NotifyMailer.payment_mail_to_consumer(admins, @payment).deliver
                @payment.offer.update_attribute(:response, "paid")
              end
              session[@offer.product_id.to_s] = nil
              flash[:notice] = "Thank you for your purchase."
              render :template => "/products/success"
              return
            else
              flash[:error] = "#{msg}"
            end
          else
              field_name = @payment.errors.first[0]
              flash[:error] = "Please enter valid #{field_name.to_s.titleize}"
          end
      end
    else
      redirect_to "/"
    end
  end

  def download_pdf
    if params[:id]
      @payment = Payment.find_by_id(params[:id])
      if @payment.nil?
        redirect_to root_path
        return
      end
      output= render_to_string :partial => "partials/pdf_letter", :object => @payment
      kit = PDFKit.new(output, :page_size => 'Letter')
      pdf = kit.to_pdf
      send_data pdf, :filename => "mypricevoucher.pdf", :type => "application/pdf"
    else
      redirect_to root_path
    end
  end
  
  def show
    if params[:id]
      @product = Product.find_by_id(params[:id])
      if @product.nil?
        redirect_to root_path
        return
      end
      offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))

      @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
      if request.post?
        if @last_offer and @last_offer.accepted?
          return
        end
        if params[:submit_button]
          submit = params[:submit_button].strip.downcase
          if ["yes", "no"].include? submit
            if submit == "no"
              @last_offer.update_attribute(:response, "rejected")
              flash[:error] = "Sorry we can't make a deal right now. Try again later?"
            elsif submit == "yes"
              @last_offer.update_attribute(:response, "accepted")
              flash[:notice] = (@last_offer.price == 0) ? "Cool! Congrats! you won free Dealkat khakis. Share with facebook /twitter friends!" : "Cool come on down to the show!"
            end
            for offer in @product.offers.all(:conditions => ["ip = ? and token = ? and id < ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @last_offer.id])
              offer.update_attribute(:response, "expired") unless ["paid", "accepted", "rejected"].include? offer.response
            end
            return
          end
        end
        price = params[:price].to_f.ceil
        
        if price <= 0
            flash[:error] = "Hi, please enter a non-zero number and we can play"
        else
          if @last_offer and @last_offer.counter?
              @offer = @product.offers.last(:conditions => ["ip = ? and token = ? and response IS NULL", request.remote_ip, offer_token])
              if @offer
                if price >= @last_offer.price
                  @last_offer.update_attribute(:response, "accepted")
                  flash[:notice] = "Cool come on down to the show!"
                  return
                end
                if(price > @offer.price)
                    @offer.update_attributes(:price => price, :counter => (@offer.counter + 1))
                    max_per = ((@last_offer.price*100)/@product.reg_price(session[:no_of_tickets])).to_i
                    rand_per = (max_per > 50 ? ((rand(999)%(max_per-50)) + 50) : max_per)
                    @new_offer = with_precision((@product.reg_price(session[:no_of_tickets]).to_f*(rand_per.to_f/100)), :precision => 0).to_f.ceil
                    if @new_offer <= with_precision(@product.floor_price(session[:no_of_tickets]), :precision => 0).to_f.ceil
                      @new_offer = with_precision(@product.floor_price(session[:no_of_tickets]), :precision => 0).to_f.ceil
                    end
                    puts "-"*50
                    puts [@new_offer, @offer.price, @last_offer.price].inspect
                    puts "-"*50
                    if @new_offer.to_f >= @last_offer.price
                      @last_offer.update_attributes(:response => "last")                    
                    elsif @new_offer.to_f <= @offer.price
                      @product.offers.update_all("response='expired'", ["ip = ? and token = ? and id <= ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @last_offer.id])
                      @last_offer.update_attributes(:price => @offer.price, :response => "accepted")
                    elsif @new_offer <= with_precision(@product.floor_price(session[:no_of_tickets]), :precision => 0).to_f.ceil
                      @new_offer = @product.floor_price(session[:no_of_tickets])
                      @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1), :response => "last")
                    
                    else
                      if((rand(999)%2) == 1)
                        @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1))
                      else
                        @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1), :response => "last")
                      end
                    end
                else
                    flash[:notice] = "Hey, please enter an offer greater than the last one!"
                    # flash[:notice] = "Hey, deal? Thanks!"
                    return
                end
              else
                return
              end
          else
              @offer = Offer.new(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => price, :counter => 1)
              @offer.save
              @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
              puts "-"*50
              puts price
              puts @product.min_price(session[:no_of_tickets])
              puts "-"*50
              if(price <= @product.min_price(session[:no_of_tickets]))
                  @new_offer = with_precision((@product.reg_price(session[:no_of_tickets]).to_f*0.95), :precision => 0).to_f.ceil
                  Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                  flash[:notice] = "Hi, $#{price} is too low. How about $#{@new_offer}?"
              elsif(price >= @product.reg_price(session[:no_of_tickets]).to_f*0.95)
                  @new_offer = with_precision((@product.reg_price(session[:no_of_tickets]).to_f*0.95), :precision => 0).to_f.ceil
                  Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "counter", :counter => 1)
                  @counter_offer = @product.offers.last(:conditions => ["ip = ? and token =? and response = ?", request.remote_ip, offer_token, 'counter'])
                  for offer in @product.offers.all(:conditions => ["ip = ? and token = ? and id <= ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @offer.id])
                    offer.update_attribute(:response, "expired") unless ["paid", "accepted", "rejected"].include? offer.response
                  end
                  @counter_offer.update_attribute(:response, "accepted")
                  if price >= @product.reg_price(session[:no_of_tickets])
                    flash[:notice] = "Hey, don't overspend. Yours for only $#{@new_offer}"
                  else
                    flash[:notice] = "Cool come on down to the show!"
                  end
              else
                  price_per = ((price*100)/@product.reg_price(session[:no_of_tickets]).to_f).ceil
                  price_per = ((price_per < 50) ? 50 : price_per)
                  rand_per = ((price_per < 95) ? ((rand(999)%(95-price_per)) + price_per) : 95)
                  @new_offer = with_precision((@product.reg_price(session[:no_of_tickets]).to_f*(rand_per.to_f/100)), :precision => 0).to_f.ceil
                  
                  if @new_offer <= with_precision(@product.floor_price(session[:no_of_tickets]), :precision => 0).to_f.ceil
                    @new_offer = @product.floor_price(session[:no_of_tickets])
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                    flash[:notice] = "Hey, the best we can do is $#{@new_offer} Deal?"
                  elsif price >= @new_offer.to_f
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                    flash[:notice] = "Hey, the best we can do is $#{@new_offer} Deal?"
                  else
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "counter", :counter => 1)
                    flash[:notice] = "Hi, we can do $#{@new_offer} Deal?"
                  end
              end
              return
          end
          @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
          new_price = with_precision(@last_offer.price, :precision => 0).to_f.ceil
          if @last_offer.last?
            flash[:notice] = "Hey, the best we can do is $#{new_price} Deal?"
          elsif @last_offer.accepted?
            flash[:notice] = "Cool come on down to the show!"
          else
            flash[:notice] = "Hi, we can do $#{new_price} Deal?"
          end
          return
        end
      end
    end
  end
end
