# Config for RZR settings
# --------------
{findParent, projectRoot} = require '../lib/coffee-script/config'

test "project root null", ->
  console.log projectRoot()
  eq projectRoot(), null, "'#{projectRoot()}' should be null"

test "project root current", ->
  eq findParent(process.cwd(), () -> true), process.cwd()

