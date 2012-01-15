(function() {
  var CoffeeScript, appMacros, exists, findParent, join, m, names, normalize, projectRoot, readdirSync, root, rzrRootTest, _i, _len, _ref, _ref2,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  CoffeeScript = require('./coffee-script');

  readdirSync = require('fs').readdirSync;

  _ref = require('path'), exists = _ref.exists, normalize = _ref.normalize, join = _ref.join;

  root = null;

  exports.findParent = findParent = function(dir, pred) {
    var upDir;
    if (dir === '/') return null;
    if (pred(dir)) {
      return dir;
    } else {
      upDir = normalize(dir + '/..');
      return findParent(upDir, pred);
    }
  };

  rzrRootTest = function(dir) {
    return __indexOf.call(readdirSync(dir), 'domain') >= 0;
  };

  exports.projectRoot = projectRoot = function() {
    return root != null ? root : root = findParent(process.cwd(), rzrRootTest);
  };

  appMacros = join(projectRoot(), "macros.coffee");

  if (require.resolve(appMacros)) {
    exports.macros = [
      {
        name: 'load',
        className: 'Load',
        tokenName: 'LOAD',
        classDef: function() {
          var Load;
          return Load = (function(_super) {

            __extends(Load, _super);

            Load.name = 'Load';

            function Load() {
              return Load.__super__.constructor.apply(this, arguments);
            }

            Load.prototype.compileNode = function(o) {
              var code, path;
              code = this.args[0].compile(o);
              path = support.getModulePath(domainRoot(), code);
              return "require('" + path + ".js');";
            };

            return Load;

          })(this.Macro);
        }
      }
    ];
    _ref2 = exports.macros;
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      m = _ref2[_i];
      names = m.name;
    }
    console.log("found these macros: " + names);
  } else {
    console.log('no macros found');
  }

}).call(this);
