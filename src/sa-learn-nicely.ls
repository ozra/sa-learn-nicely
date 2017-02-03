fs = require "fs-ext"
{exec-sync} = require "child_process"

Number::seconds = -> this * 1000

now = -> Date.now()

say = (...args) ->
   out = ""
   for arg in args
      out += arg # .to-string
   console.log out

_D = say

CHECK-INTERVAL = 3.seconds!
TIMEOUT = 60.seconds!
SPAM-DIR = "/var/tmp/sa-learn-pipeline/"
LEARN-BIN = "/usr/bin/sa-learn"
# LEARN-BIN = "no-op"
# MAIL-USER = "vmail"
PID-FILE = "/var/run/sa-learn-nicely.pid"
_D CHECK-INTERVAL
_D TIMEOUT
_D SPAM-DIR
# _D MAIL-USER

check-for-things-to-do = ->
   check-for-spam-training()
   return

check-for-spam-training = ->
   try
      filenames = fs.readdir-sync SPAM-DIR
   catch err
      say "Had an error! ", err
      return err

   # _D "got filenames: ", filenames

   for filename in filenames
      do-spam-training filename

   return

do-spam-training = (filename) ->
   filename = SPAM-DIR + filename
   try
      fd = fs.open-sync filename, "r"
   catch err
      say "Error opening file #{filename}! ", err
      return

   try
      fs.flock-sync fd, "ex" 
      fs.flock-sync fd, "un"
   catch err
      say "File \"#{filename}\" wasn't ready, catch it next time."
      return
      
   # if we get here we were able to lock the file, so work it
   name-parts = filename.split /--/
   verdict = "--" + name-parts.1
   cmd = "#{LEARN-BIN} #{verdict} #{filename} && rm -f #{filename} &"
   say cmd

   try
      exec-sync cmd
   catch err
      say "Got error executing sa-learn: ", err
   return

started-running = 0

forever = ->
   return if now() - started-running < TIMEOUT
   started-running := now()
   check-for-things-to-do()
   started-running := 0
   return

verify-fs-integrity = ->
   # pointless exercise - let the pile-up script do it so we don't have to worry about username here
   # try
   #    exec-sync "mkdir -p #{SPAM-DIR}"
   # catch err
   #    say "error while ensuring tmp-dirs exist!"
   return

do-pid-stuff = ->
   try
      prev-pid = fs.read-file-sync PID-FILE
      fs.write-file-sync PID-FILE, process.pid.to-string()
      process.kill prev-pid

   catch err
      fs.write-file-sync PID-FILE, process.pid.to-string()
      prev-pid = ""

main = ->
   do-pid-stuff()
   verify-fs-integrity()
   set-interval forever, CHECK-INTERVAL
   return

main()

