CoffeeScript = require './coffee-script'
{readdirSync} = require 'fs'
{exists, normalize, join} = require 'path'

# ============================================================
# Find root project directory
# ============================================================
root = null

exports.findParent = findParent = (dir, predicate) ->
  return null if dir == '/'

  if predicate(dir)
    return dir
  else
    upDir = normalize(dir + '/..')
    return findParent(upDir, predicate)

rzrRootTest = (dir) ->
  'domain' in readdirSync(dir)

#try to find project root
exports.projectRoot = projectRoot = () ->
  root ?= findParent process.cwd(), rzrRootTest

# ============================================================
# load macros file if it exists
# ============================================================
exports.macros = []
appMacros = join projectRoot(), "macros.coffee" #/config
if require.resolve appMacros
  #{macros} = require appMacros

  #exports.macros = macros
  #exports.macros = [
    #{
      #name: 'load'
      #className: 'Load'
      #tokenName: 'LOAD'
      #classDef: ->
        #class Load extends this.Macro
          #compileNode: (o) ->
            #code = @args[0].compile o
            #path = support.getModulePath(domainRoot(), code)
            #"require('#{ path }.js');"
    #}
    #macro 'load', (o, args, projectRoot) ->
      #throw SyntaxError 'load takes one argument' unless @args.length == 1
      #{join} = require 'path'

      #code = eval args[0].compile(o)
      #domainRoot = join projectRoot, 'domain'
      ##path = getModulePath(domainRoot, code)

      #"require('#{ domainRoot }.js');"
  #]

  names = m.name for m in exports.macros
  if names?
    console.log "found these macros: #{names}"
  else
    console.log 'no macros found'

else
    console.log 'project root not found'

