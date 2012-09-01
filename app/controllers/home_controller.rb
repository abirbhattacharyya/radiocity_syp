class HomeController < ApplicationController
  before_filter :check_login, :only => [:notifications, :analytics]

  def index
    if params[:signed_request]
      begin
        signed_request = parse_signed_request(params, oauth_secret("facebook"))
        if signed_request["user_id"]
          session[:signed_request] = params[:signed_request]
        else
          redirect_to :action => "callback"
        end
      rescue => e
        # render :text => e.message.inspect and return false
        redirect_to :action => "callback" and return
      end
    else
      flash.discard
      if logged_in?
        if current_user.profile.nil?
          render :template => "users/profile"
        elsif current_user.products.empty?
          render :template => "products/new"
        else
          @notifications = [["profile", current_user.profile.created_at], ["products", current_user.products.last.created_at]]
          @last_action_on = @notifications.sort{|n1, n2| n2[1] <=> n1[1]}.first[1]
          render :template => "/home/notifications"
        end
      end
    end
  end

  def callback
      if params[:code]
        url = "https://graph.facebook.com/oauth/access_token?client_id=#{oauth_key("facebook")}&redirect_uri=#{callback_url("facebook")}&client_secret=#{oauth_secret("facebook")}&code=#{params[:code]}"
        data = open(url).read
        redirect_to :action => "failure" and return if data.nil? or data.blank?
        redirect_to fb_app_path
      elsif params[:error]
        redirect_to :action => "failure"
      else
        @redirect_url = "https://www.facebook.com/dialog/oauth?client_id=#{oauth_key("facebook")}&redirect_uri=#{callback_url("facebook")}"
        # redirect_to @redirect_url
        render :layout => false
      end
  end

  def failure
    redirect_to :action => "callback"
  end

  def notifications
    @notifications = [["profile", current_user.profile.created_at], ["products", current_user.products.last.created_at]]
    @last_action_on = @notifications.sort{|n1, n2| n2[1] <=> n1[1]}.first[1]
    #@notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
  end
  
  def analytics
    @today = Date.today-1.day
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @size = 5
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @titleX = "Time Period"
    @titleY = "#"
    @colors = ["blue"]
    @i = 0
    @head_line = ""

    case @page
      when @i+=1
        @head_line = "Look at your cool analytics!"
        @title = "# Of Visits"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired'")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired' and Date(offers.updated_at) = '#{Date.today}'")
      when @i+=1
        @head_line = "Even more useful data to measure!"
        @title = "# Of Negotiations"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired'")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired' and Date(offers.updated_at) = '#{Date.today}'")
      when @i+=1
        @head_line = "Track Purchases in Real-Time"
        @title = "# Of Purchases"
        @offers_a = Offer.first(:select => "COUNT(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid'")
        @offers_y = Offer.first(:select => "COUNT(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
      when @i+=1
        @head_line = "Watch your dynamic pricing dollars"
        @title = "Dollars Total Purchases"
        @titleY = "$"
        @offers_a = Offer.first(:select => "SUM(price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid'")
        @offers_y = Offer.first(:select => "SUM(price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
      when @i+=1
        @head_line = "Algorithms manage your margins in real-time!"
        @title = "Dollars Total Discount"
        @titleY = "$"

        @offers_a = Payment.first(:select => "SUM((products.regular_price*payments.quantity)-offers.price) as total", :joins => "INNER join offers on (payments.offer_id=offers.id) INNER join products on (offers.product_id = products.id) and products.user_id = #{current_user.id} and offers.response LIKE 'paid'")
        @offers_y = Payment.first(:select => "SUM((products.regular_price*payments.quantity)-offers.price) as total", :joins => "INNER join offers on (payments.offer_id=offers.id) INNER join products on (offers.product_id = products.id) and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
      else
        @title = "# Of Negotiations"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id}")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and Date(offers.updated_at) = '#{Date.today}'")
    end
     @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.options[:chart][:defaultSeriesType] = "column"
        f.options[:xAxis][:categories] = ["Today" ,"Cumulative"]
        #f.options[:xAxis][:labels] = {rotation: -45, align: 'right',style: {font: 'normal 13px Verdana, sans-serif'}}

        f.options[:yAxis][:title] = {:text => @titleY}
        f.series(:name=>'Today', :data=> [@offers_y.total.to_i,@offers_a.total.to_i])
        f.legend(false)
        f.title(:text => @title)
     end
  end

  def say_your_price
    if logged_in?
      redirect_to root_path
      return
    end
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @type = params[:type]
    @size = (@type ? Product.by_product_type(@type).count.to_i : Product.count.to_i)
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    if @type
      @products = Product.by_product_type(@type).all(:limit => "#{@per_page*(@page - 1)}, #{@per_page}")
    else
      @products = Product.all(:limit => "#{@per_page*(@page - 1)}, #{@per_page}")
    end

    @page_start_num = ((@page - 4) > 0) ? (@page - 4) : 1
    @page_end_num = ((@page_start_num + 8) > @post_pages) ? @post_pages : (@page_start_num + 8)
    @page_start_num = ((@post_pages - @page_end_num) < 8) ? (@page_end_num - 8) : @page_start_num
    @page_start_num = 1 if @page_start_num < 1
  end
  
  def winners
    @payments = Payment.all(:order => "id desc", :joins => "INNER JOIN offers ON payments.offer_id=offers.id", :limit => 100)
  end
  
  def ticket_book
    @products = []
    if params[:name]
      @ticket = params[:name]
      return
    end
    if request.post?
        offer_token = (session[:_csrf_token] ||= SecureRandom.base64(32))
        reset_session
        session[:no_of_tickets] = params[:no_of_tickets]
        @products = Product.find_all_by_name(params[:ticket])

        @size = @products.size
        @per_page = 1
        @post_pages = (@size.to_f/@per_page).ceil;

        @page = params[:page].to_i
        @page = 1 if @page < 1
        @products = Product.where(["name = ?",params[:ticket]]).limit("#{@per_page*(@page - 1)}, #{@per_page}")
        @page_start_num = ((@page - 4) > 0) ? (@page - 4) : 1
        @page_end_num = ((@page_start_num + 8) > @post_pages) ? @post_pages : (@page_start_num + 8)
        @page_start_num = ((@post_pages - @page_end_num) < 8) ? (@page_end_num - 8) : @page_start_num
        @page_start_num = 1 if @page_start_num < 1

        Offer.update_all("response = 'expired'", ["ip = ? and token = ? and (response IS NULL OR response NOT IN (?))", request.remote_ip, offer_token, ["paid", "rejected"]])
    end
  end

end
