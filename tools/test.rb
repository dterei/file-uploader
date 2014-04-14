#! /usr/bin/env ruby

require 'csv'
require 'json'

GRACE = 30 * 60
DEADLINE = Time.local(2014,4,8,12,50)

UPLOADS='submissions'
RESDIR='results'
TESTDIR='test'
TESTFILE='TestGlobber.hs'
SUBMISSION='globber-1.0.0'

def usage
  if ARGV.length != 1
    puts <<EOL
Read a file-uploader log file and test each (latest) submission for a student.

Usage: <log file>
EOL
    exit 1
  end
end

def grab_students
  logFile   = ARGV[0]
  jsonLines = File.open(logFile).read
  students  = {}

  jsonLines.each_line do |line|
    js = JSON.parse(line)
    suid = js["suid"]
    t = Time.at(js['uploaded'].to_i / 1000)
    file = js['digest']
    msg = js['message']

    if students[suid]
      if students[suid][:time] < t
        students[suid] = { :time => t, :file => file, :msg => msg }
      end
    else
      students[suid] = { :time => t, :file => file, :msg => msg }
    end
  end

  return students
end

def late_submissions(students)
  students.each do |k,v|
    if v[:time] > DEADLINE + GRACE
      days_late = ((v[:time] - DEADLINE) / (24*60*60)).ceil
      students[k][:late] = days_late
    end
  end
end

def test_submission(student, data)
  # TODO: Fill in.
end

def test_submissions(students)
  root = `pwd`.strip
  `mkdir "#{root}/#{TESTDIR}"`
  `mkdir "#{root}/#{RESDIR}"`

  File.open("#{root}/#{RESDIR}/results.csv", 'w') do |res_file|
    res_file.puts "suid,days_late,builds,tests,failed"

    students.each do |k,v|
      puts "== Student: #{k}"

      test_dir = "#{root}/#{TESTDIR}/#{k}"
      `mkdir "#{test_dir}"`
      Dir.chdir("#{test_dir}") do
        `tar xzf "#{root}/#{UPLOADS}/#{v[:file]}"`
        Dir.chdir("#{test_dir}/#{SUBMISSION}") do
          test_submission(k,v)
        end
      end
      res_file.puts "#{k},#{v[:late]},#{v[:builds]},#{v[:tests]},#{v[:failed]}"
    end
  end
end

def main
  usage
  students = grab_students
  late_submissions(students)
  test_submissions(students)
end

main

