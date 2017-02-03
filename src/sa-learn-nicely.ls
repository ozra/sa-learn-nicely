fs = require "fs-ext"
{exec-sync} = require "child_process"

Number::seconds = -> this * 1000

now = -> Date.now()

say = (...args) ->
   out = ""
   for arg in args
      out += arg # .to-string
   console.log out

_d = say

CHECK-INTERVAL = 0.001.seconds!
TIMEOUT = 60.seconds!
SPAM-DIR = "/var/tmp/sa-learn-pipeline/"
LEARN-BIN = "/usr/bin/sa-learn"
# LEARN-BIN = "no-op"


_d CHECK-INTERVAL
_d TIMEOUT
_d SPAM-DIR

check-for-things-to-do = ->
   # _d ""

   check-for-spam-training()
      
   return

check-for-spam-training = ->
   # _d "Check for spams to train on"

   try
      filenames = fs.readdir-sync SPAM-DIR
   catch err
      say "Had an error! ", err
      return err

   # _d "got filenames: ", filenames

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
   try
      exec-sync "mkdir -p #{SPAM-DIR}"
   catch err
      say "error while ensuring tmp-dirs exist!"
   return

main = ->
   verify-fs-integrity()
   set-interval forever, CHECK-INTERVAL
   return

main()

