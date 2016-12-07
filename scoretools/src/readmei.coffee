# read an mei file and look for musicodes
# they seem to be div / rend text() 
# although other things are too...

if process.argv.length != 3
  console.log 'Usage: node makemuzicodes <meifile>'
  process.exit -1

fs = require 'fs'
getCodeIds = (require './meiutils').getCodeIds

meifile = process.argv[2]
console.log 'read mei file '+meifile
mei = null
try 
  mei = fs.readFileSync meifile, 'utf8'
catch e 
  console.log 'error reading mei file '+meifile+': '+e.message
  process.exit -2

ids = getCodeIds mei
console.log 'found: '+(JSON.stringify ids)
