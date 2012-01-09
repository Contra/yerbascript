{readdirSync} = require 'fs'
{normalize, join} = require 'path'

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

exports.projectRoot = projectRoot = () ->
  root ?= findParent process.cwd(), rzrRootTest

if projectRoot()
  # support.coffee loads all support modules and exports them?
  exports.support = require(join projectRoot(), "support/support.coffee")
