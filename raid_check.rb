#!/usr/bin/ruby -w

require 'mail'

# set up email creds
# edit this with the correct creds for your mail server. 
Mail.defaults do
  delivery_method :smtp, { :address => "smtp.example.com",
    :port => 587,
    :domain => 'example.com',
    :user_name => 'your_username',
    :password => 'password',
    :authentication => 'plain',
    :enable_starttls_auto => true  }
end


# get the latest alarms
def get_alarms
	@alarm_list = `tw_cli show alarms reverse`.split("\n")
end

# check alarms for errors or warnings
def find_problems(list)
	@problems = ""
	list.each do |line|
		if line.match("ERROR|WARNING")
			@problems = @problems + line + "\n"
		end
	end
end



# if alarms are found, send an email
# edit this with your email info
def send_email(error_list)

	Mail.deliver do
	    to 'youremail@example.com'
	    from 'fromaddress@example.com'
	    subject 'Raid Errors/Warnings Found On Server "SERVERNAME"'
	    body "The following alerts were found in the last 24 hours:\n\n#{error_list}"
    end

end




get_alarms

find_problems(@alarm_list)

unless @problems.empty?
	send_email(@problems)
end












