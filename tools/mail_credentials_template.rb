require 'mail'

def setup_mail
  options = {
    :address   => 'smtp.gmail.com',
    :port      => 587,
    :domain    => '?',
    :user_name => '?',
    :password  => '?',
    :authentication => 'plain',
    :enable_starttls_auto => true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end
end
