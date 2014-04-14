#! /usr/bin/env ruby

require 'csv'
require 'mail'
# setup_mail.rb shoud contain your mail credentials.
load './setup_mail.rb'

DOMAIN='@scs.stanford.edu'
FROM='no-reply@scs.stanford.edu'
SUBJ='<Email Subject>'

def body(build, late, tests, fails)
  # TODO: Fill in.
  body = <<EOF
Your results are:

* Builds: #{build}
* Tests run: #{tests}
* Tests passed: #{tests - fails}
* Tests failed: #{fails}

You submission was #{late}. Thanks!
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
    subject SUBJ
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

    if !late 
      late = 'on time'
    elsif late.to_i > 1
      late = late + ' days late'
    else
      late = late + ' day late'
    end

    send_mail(suid + DOMAIN, body(build, late, tests, fails))
  end
end

def main
  results = usage
  setup_mail
  process_results(results)
end

main

