CoffeeScript = require './coffee-script'
{readdirSync} = require 'fs'
{exists, normalize, join} = require 'path'

# ============================================================
# Find root project directory
# ============================================================
root = null

exports.findParent = findParent = (dir, pred) ->
  return null if dir == '/'

  if pred(dir)
    return dir
  else
    upDir = normalize(dir + '/..')
    return findParent(upDir, pred)

rzrRootTest = (dir) ->
  'domain' in readdirSync(dir)

#try to find project root
exports.projectRoot = projectRoot = () ->
  root ?= findParent process.cwd(), rzrRootTest

# ============================================================
# load macros file if it exists
# ============================================================
appMacros = join projectRoot(), "macros.coffee"
if require.resolve appMacros
  #{macros} = require appMacros

  #exports.macros = macros
  exports.macros = [
    {
      name: 'load'
      className: 'Load'
      tokenName: 'LOAD'
      classDef: ->
        class Load extends this.Macro
          compileNode: (o) ->
            code = @args[0].compile o
            path = support.getModulePath(domainRoot(), code)
            "require('#{ path }.js');"
    }
  ]

  names = m.name for m in exports.macros
  console.log "found these macros: #{names}"

else
  console.log 'no macros found'

