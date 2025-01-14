# CoffeeScript can be used both on the server, as a command-line compiler based
# on Node.js/V8, or to run CoffeeScripts directly in the browser. This module
# contains the main entry functions for tokenizing, parsing, and compiling
# source CoffeeScript into JavaScript.
#
# If included on a webpage, it will automatically sniff out, compile, and
# execute all scripts present in `text/coffeescript` tags.

fs               = require 'fs'
path             = require 'path'
{Lexer,RESERVED} = require './lexer'
{parser}         = require './parser'
vm               = require 'vm'

# TODO: Remove registerExtension when fully deprecated.
if require.extensions
  require.extensions['.coffee'] = (module, filename) ->
    content = compile fs.readFileSync(filename, 'utf8'), {filename}
    module._compile content, filename
  require.extensions['.yerba'] = (module, filename) ->
    content = compile fs.readFileSync(filename, 'utf8'), {filename}
    module._compile content, filename
else if require.registerExtension
  require.registerExtension '.yerba', (content) -> compile content
  require.registerExtension '.coffee', (content) -> compile content

# The current CoffeeScript version number.
exports.VERSION = '1.2.1-pre'

# Words that cannot be used as identifiers in CoffeeScript code
exports.RESERVED = RESERVED

# Expose helpers for testing.
exports.helpers = require './helpers'

# Compile a string of CoffeeScript code to JavaScript, using the Coffee/Jison
# compiler.
exports.compile = compile = (code, options = {}) ->
  {merge} = exports.helpers
  try
    (parser.parse lexer.tokenize code).compile merge {}, options
  catch err
    err.message = "In #{options.filename}, #{err.message}" if options.filename
    throw err

# Tokenize a string of CoffeeScript code, and return the array of tokens.
exports.tokens = (code, options) ->
  lexer.tokenize code, options

# Parse a string of CoffeeScript code or an array of lexed tokens, and
# return the AST. You can then compile it by calling `.compile()` on the root,
# or traverse it by using `.traverseChildren()` with a callback.
exports.nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

# Compile and execute a string of CoffeeScript (on the server), correctly
# setting `__filename`, `__dirname`, and relative `require()`.
exports.run = (code, options) ->
  mainModule = require.main

  # Set the filename.
  mainModule.filename = process.argv[1] =
      if options.filename then fs.realpathSync(options.filename) else '.'

  # Clear the module cache.
  mainModule.moduleCache and= {}

  # Assign paths for node_modules loading
  mainModule.paths = require('module')._nodeModulePaths path.dirname options.filename

  # Compile.
  if path.extname(mainModule.filename) isnt '.coffee' or require.extensions
    mainModule._compile compile(code, options), mainModule.filename
  else
    mainModule._compile code, mainModule.filename

# Compile and evaluate a string of CoffeeScript (in a Node.js-like environment).
# The CoffeeScript REPL uses this to run the input.
exports.eval = (code, options = {}) ->
  return unless code = code.trim()
  Script = vm.Script
  if Script
    if options.sandbox?
      if options.sandbox instanceof Script.createContext().constructor
        sandbox = options.sandbox
      else
        sandbox = Script.createContext()
        sandbox[k] = v for own k, v of options.sandbox
      sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox
    else
      sandbox = global
    sandbox.__filename = options.filename || 'eval'
    sandbox.__dirname  = path.dirname sandbox.__filename
    # define module/require only if they chose not to specify their own
    unless sandbox isnt global or sandbox.module or sandbox.require
      Module = require 'module'
      sandbox.module  = _module  = new Module(options.modulename || 'eval')
      sandbox.require = _require = (path) ->  Module._load path, _module, true
      _module.filename = sandbox.__filename
      _require[r] = require[r] for r in Object.getOwnPropertyNames require when r isnt 'paths'
      # use the same hack node currently uses for their own REPL
      _require.paths = _module.paths = Module._nodeModulePaths process.cwd()
      _require.resolve = (request) -> Module._resolveFilename request, _module
  o = {}
  o[k] = v for own k, v of options
  o.bare = on # ensure return value
  js = compile code, o
  if sandbox is global
    vm.runInThisContext js
  else
    vm.runInContext js, sandbox

# Instantiate a Lexer for our use here.
lexer = new Lexer

# The real Lexer produces a generic stream of tokens. This object provides a
# thin wrapper around it, compatible with the Jison API. We can then pass it
# directly as a "Jison lexer".
parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

parser.yy = require './nodes'
