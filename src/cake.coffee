{spawn, exec} = require 'child_process'
path = require 'path'
fs = require 'fs'
glob = require 'glob'
log = console.log


module.exports = (task) ->

  baseDir = path.resolve(path.join(__dirname, '..'))
  binDir = path.join(baseDir, 'node_modules', '.bin')
  coffeeLintPath = path.resolve(path.join(baseDir, 'coffeelint.json'))


  task 'build', ->
    run "rm -fr ./lib; #{binDir}/coffee -o lib -c src"


  task 'lint', ->
    run "#{binDir}/coffeelint -f #{coffeeLintPath} src/*"


  task 'pdf', ->
    docsPath = "#{process.cwd()}/docs"

    log 'glob', "#{docsPath}/{,**/}*.md"
    mdFiles = glob.sync "#{docsPath}/{,**/}*.md", nocase: true
    return log('> no files in ./docs') unless mdFiles.length

    version = require(path.join(process.cwd(), 'package.json')).version

    # if there's a Google Drive symlink, output to that, otherwise use the same directory as the docs
    drivePath = try fs.statSync('./drive') and './drive' catch

    for mdFile in mdFiles
      pdfDir = path.dirname(mdFile)
      pdfDir = pdfDir.replace(docsPath, drivePath) if drivePath
      fileBaseName = path.basename(mdFile, path.extname(mdFile))
      pdfFile = "#{pdfDir}/#{fileBaseName}.#{version}.pdf"
      log "creating #{pdfFile}..."
      run "#{binDir}/markdown-pdf #{mdFile} -o #{pdfFile}", stderr: false


  option '-p', '--path [DIR]', 'path to test file'
  task 'test', (options) ->
    file = options.path or ''
    pattern = "spec/{,**/}#{file}*-spec.coffee"
    log("Running tests at #{pattern}...")
    run "NODE_ENV=test TZ=GMT #{binDir}/mocha --compilers coffee:coffee-script/register --reporter spec --colors  --recursive '#{pattern}'"



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
  if options?.stderr
    cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', ->
    cmd.kill()
  cmd.on 'exit', (code) ->
    process.exit(code)
