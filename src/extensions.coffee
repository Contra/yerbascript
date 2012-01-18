{CoffeeScript} = require './coffee-script'
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

  #exports.macros.push macros
  #exports.macros.push [
    #{
      #name: 'foo'
      #className: 'Foo'
      #tokenName: 'FOO'
      #classDef: ->
        #class Foo extends this.Macro
          #compileNode: (o) ->
            #code = @args[0].compile o
            #path = support.getModulePath(domainRoot(), code)
            #"require('#{ path }.js');"
    #}
  #]...

  names = (m.name for m in exports.macros)
  if names?
    console.log "found these macros: #{names}"
  else
    console.log 'no macros found'

else
    console.log 'project root not found'

