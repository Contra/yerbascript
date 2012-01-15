# Config for RZR settings
# --------------
{findParent, projectRoot} = require '../lib/coffee-script/extensions'

test "project root null", ->
  eq projectRoot(), null, "'#{projectRoot()}' should be null"

test "project root current", ->
  eq findParent(process.cwd(), () -> true), process.cwd()

