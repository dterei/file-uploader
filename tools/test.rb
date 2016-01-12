#! /usr/bin/env ruby

require 'csv'
require 'json'

RESDIR='results'
TESTDIR='test'
GRACE = 30 * 60

# TODO: Customize for lab
DEADLINE = Time.local(2016,1,11,15,00)
SUBMISSION='<SUBMISSION>'
TESTFILE='<FILE>'

def usage
  if ARGV.length != 2
    puts <<EOL
Read a file-uploader log file and test each (latest) submission for a student.

Usage: <log file> <submissions directory>
EOL
    exit 1
  end
  return ARGV
end

def grab_students(logFile)
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
    else
      students[k][:late] = 0
    end
  end
end

# TODO: Customize for lab
def test_submission(student, subm)
  if not (system "cp \"#{TESTFILE}\" test/")
    subm[:builds] = false
    return
  end

  if not (system "stack build 1> ../build.stdout 2> ../build.stderr")
    subm[:builds] = false
    return
  end

  if not (system "stack build 1>> ../build.stdout 2>> ../build.stderr")
    subm[:builds] = false
    return
  end

  system "stack test 1>> ../test.stdout 2>> ../test.stderr"
  subm[:builds] = true
  subm[:tests]  = `cat ../test.stdout | tail -1 | cut -d' ' -f1`.strip
  subm[:failed] = `cat ../test.stdout | tail -1 | cut -d' ' -f3`.strip
end

def run_submission(res_file, tarDir, student, subm)
  puts "== Student: #{student}"

  root = `pwd`.strip
  test_dir = "#{root}/#{TESTDIR}/#{student}"
  tar_file = File.expand_path("#{tarDir}/#{subm[:file]}")
  `mkdir -p "#{test_dir}"`

  Dir.chdir("#{test_dir}") do
    puts "submission: #{tar_file}"
    `tar xzf "#{tar_file}" || tar xf "#{tar_file}"`
    Dir.chdir("#{test_dir}/#{SUBMISSION}") do
      test_submission(student,subm)
    end
  end
  res_file.puts "#{student},#{subm[:late]},#{subm[:builds]},"\
    "#{subm[:tests]},#{subm[:failed]}"
end

def test_submissions(students, tarDir)
  root = `pwd`.strip
  `mkdir -p "#{root}/#{TESTDIR}"`
  `mkdir -p "#{root}/#{RESDIR}"`

  File.open("#{root}/#{RESDIR}/results.csv", 'w') do |res_file|
    res_file.puts "suid,days_late,builds,tests,failed"
    students.each do |k,v|
      begin
        run_submission(res_file, tarDir, k, v)
      rescue Exception => e
        puts "\n* FAILURE: #{k} *"
        puts e.message
        puts ""
      end
    end
  end
end

def main
  logFile, tarDir = usage
  students = grab_students(logFile)
  late_submissions(students)
  test_submissions(students, tarDir)
end

main

