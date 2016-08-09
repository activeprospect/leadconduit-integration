{spawn, exec} = require 'child_process'
fs = require 'fs'
log = console.log

toolBase = './node_modules/leadconduit-integration/'


task 'build', ->
  run "#{toolBase}/node_modules/coffee-script/bin/coffee -o lib -c src"


task 'clean', ->
  run 'rm -fr ./lib'


task 'lint', ->
  run "#{toolBase}/node_modules/coffeelint/bin/coffeelint -f #{toolBase}/coffeelint.json src/*"


task 'pdf', ->
  docsPath = './docs'

  if exists(docsPath)
    version = require('./package.json').version
    for mdFile in fs.readdirSync(docsPath).filter((f) -> f.endsWith('.md'))
      outdir = if exists('./drive') then './drive' else docsPath # if there's a Google Drive symlink, output to that
      outfile = "#{outdir}/" + mdFile.replace('.md', ".#{version}.pdf")
      console.log "creating #{outfile}..."
      run "#{toolBase}/node_modules/markdown-pdf/bin/markdown-pdf #{docsPath}/#{mdFile} -o #{outfile}"
  else
    console.log '> no PDF generated.'


task 'test', ->
  run 'NODE_ENV=test TZ=GMT ./node_modules/.bin/mocha spec/* --compilers coffee:coffee-script/register --reporter spec --colors'


exists = (path) ->
  f = null
  try
    f = fs.statSync(path)
  catch e
    if e.code == 'ENOENT'
      console.log "> #{e.path} not found"
    else
      console.log "> error reading #{path}: ", e

  f?


run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a

  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', ->
    cmd.kill()
  cmd.on 'exit', (code) ->
    process.exit(code)
