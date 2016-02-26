#!/usr/bin/env ruby

require 'csv'
require 'mail'
# TODO: mail_credentials.rb shoud contain your SMTP setup.
load './mail_credentials.rb'

DOMAIN='@domain.edu'
FROM='@domain.edu'
SUBJ='email subject'
SOLN='<SOLN UR>'
NAME='<NAME>'

def body(build, late, tests, fails, notes)
  # TODO: Fill in.
  body = <<EOF
Your #{SUBJ} are:

* Builds: #{build}
* Tests run: #{tests}
* Tests passed: #{tests - fails}
* Tests failed: #{fails}

* Grade: #{tests - fails} / #{tests} (before late penalties, if any)
* You submission was: #{late}

* Notes: #{notes}

We won't be providing individual feedback on the code sorry, instead we have a
reference solution you can look at here:

#{SOLN}

So you can see where you went wrong by checking against this testsuite. Come to
office hours if you'd like more feedback!

Your friendly TA,
#{NAME}
EOF
  return body
end

def usage
  if ARGV.length != 1
    puts <<EOL
Read a results CSV file and send an email to each student with their results.

Usage: <csv results file>
EOL
    exit 1
  end

  return ARGV[0]
end

def send_mail(to_email, body)
  Mail.deliver do
    to to_email
    from FROM
    subject (SUBJ.split.map {|x| x.capitalize}).join(' ')
    body body
  end
end

def process_results(results)
  CSV.foreach(results, :headers => true) do |row|
    suid  = row[0]
    late  = row[1]
    build = row[2]
    tests = row[3].to_i
    fails = row[4].to_i
    notes = row[5]

    if !late 
      late = 'on time'
    elsif late.to_i > 1
      late = late + ' days late'
    else
      late = late + ' day late'
    end

    send_mail(suid + DOMAIN, body(build, late, tests, fails, notes))
  end
end

def main
  results = usage
  setup_mail
  process_results(results)
end

main

