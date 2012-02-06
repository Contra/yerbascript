#notice, system installed coffee-script, not yerbascript
cs = require 'coffee-script'
{readdirSync} = require 'fs'
path = require 'path'

# ============================================================
# Find root project directory
# ============================================================
root = null

exports.findParent = findParent = (dir, predicate) ->
  return null if dir == '/'

  if predicate(dir)
    return dir
  else
    upDir = path.normalize(dir + '/..')
    return findParent(upDir, predicate)

rzrRootTest = (dir) ->
  'domain' in readdirSync(dir)

#try to find project root
exports.projectRoot = projectRoot = () ->
  root ?= findParent process.cwd(), rzrRootTest

# ============================================================
# load macros file if it exists
# ============================================================
exports.macros = {}
appMacros = path.join projectRoot(), "macros.coffee" #/config

if projectRoot? && path.existsSync appMacros
  {macros} = require appMacros
  toCamel = (str) -> str.replace /^[a-z]/g, (firstChar) -> firstChar.toUpperCase()

  for name, fn of macros
    className = toCamel(name)

    exports.macros[name] =
      className: className
      tokenName: name.toUpperCase()
      classDef: eval(cs.compile """
          ->
            class #{className} extends this.Macro
              compileNode: (o) ->
                ( `#{fn}` )(@args, compileContext: o, projectRoot: projectRoot())
        """, {bare: true})

  names = (name for name, def of exports.macros)
  if names.length > 0
    console.log "found these macros: #{names}"
  else
    console.log 'no macros found'

else
    console.log 'project root not found: no macros loaded'
