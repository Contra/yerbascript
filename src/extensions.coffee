{readdirSync} = require 'fs'
{normalize, existsSync, join, dirname} = require 'path'
{Macro} = require './nodes'

# ============================================================
# Find root project directory aka folder with macros file
# ============================================================
getMacros = (start, last) ->
  macroFile = 'macros'
  start ?= process.cwd() # Start off wherever the process was started
  if start is '/' or start is '\\' # we got all the way to root
    unless last # try starting from the yerba dir
      start = __dirname
      last = true
    else # already tried cwd and yerba dir, quit trying
      return
  # Try to require macros
  try
    return require.resolve normalize "#{start}/#{macroFile}"
  catch e
    return getMacros join(start, '..'), last

# ============================================================
# load macros file if it exists
# ============================================================
exports.macros = {}
appMacros = getMacros()
exports.projectRoot = projectRoot = dirname appMacros

console.log "Macro file: #{appMacros}"
console.log "Project root: #{projectRoot}"

if appMacros? and projectRoot?
  {macros} = require appMacros
  toCamel = (str) -> str.replace /^[a-z]/g, (firstChar) -> firstChar.toUpperCase()

  for name, fn of macros
    clazz = new Macro
    clazz.compileNode = (o) => fn @args, compileContext: o, projectRoot: projectRoot

    exports.macros[name] =
      className: toCamel name
      tokenName: name.toUpperCase()
      classDef: clazz

  names = (name for name, def of exports.macros)
  if names.length > 0
    console.log "Macros loaded: #{names}"