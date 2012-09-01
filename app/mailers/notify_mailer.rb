class NotifyMailer < ActionMailer::Base
  default :from => '"Dealkat" <dk@dealkat.com>'

  def forgot(user)
    @user = user
    mail(:to => user.email, :subject =>  'Your forgotten password for Dealkat')
  end

  def sendcoupon(recipient, payment)
    @payment = payment
    mail(:bcc => recipient , :subject => "Congrats on Your Say Your Price Purchase")
  end

  def payment_mail_to_consumer(recipient, payment)
    @payment = payment
    mail(:bcc => recipient, :subject => 'Your Perry South Beach Hotel Reservation')
  end

  def payment_mail_to_merchant(recipient, payment)
    @payment = payment
    mail(:bcc => recipient, :subject => 'Confirmed Dealkat Reservation')
  end

  def dailyreport(recipient, todays_coupons, all_coupons, analytics_today, analytics_overall, todays_dollars, overall_dollars, today)
    @todays_coupons = todays_coupons; @all_coupons = all_coupons
    @analytics_today = analytics_today; @analytics_overall = analytics_overall
    @todays_dollars = todays_dollars; @overall_dollars = overall_dollars; @today = today
    mail(:bcc => recipient, :subject => 'daily status report')
  end
end
