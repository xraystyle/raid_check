#!/usr/bin/ruby -w

require 'mail'
require 'time'

@hostname = `hostname`

# Edit these as appropriate. 
@to_email = "your_email@example.com"
@from_email = "from_address@example.com"

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

############## Methods ##############

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
	    to @to_email
	    from @from_email
	    subject "Raid Errors/Warnings Found On Server \"#{@hostname}\""
	    body "The following alerts were found in the last 24 hours:\n\n#{error_list}"
    end

end

# Narrow problem list to errors/warnings that have occured in the last 24 hours.
def new_problems(problem_list)
	current_time = Time.now
	@recent_problems = ""
	problem_list = problem_list.split("\n")
	problem_list.each do |line|
		t_match = line.match('\[(.*)\]')
		line_time = Time.parse(t_match[1])

		if current_time - line_time < 86400
			
			@recent_problems = @recent_problems + line + "\n"
			
		end

	end

end

############## Start Script ##############


get_alarms

find_problems(@alarm_list)

new_problems(@problems)

unless @recent_problems.empty?
	send_email(@recent_problems)
end



