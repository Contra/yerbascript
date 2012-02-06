(function() {
  var appMacros, className, cs, def, findParent, fn, macros, name, names, path, projectRoot, readdirSync, root, rzrRootTest, toCamel,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  cs = require('coffee-script');

  readdirSync = require('fs').readdirSync;

  path = require('path');

  root = null;

  exports.findParent = findParent = function(dir, predicate) {
    var upDir;
    if (dir === '/') return null;
    if (predicate(dir)) {
      return dir;
    } else {
      upDir = path.normalize(dir + '/..');
      return findParent(upDir, predicate);
    }
  };

  rzrRootTest = function(dir) {
    return __indexOf.call(readdirSync(dir), 'domain') >= 0;
  };

  exports.projectRoot = projectRoot = function() {
    return root != null ? root : root = findParent(process.cwd(), rzrRootTest);
  };

  exports.macros = {};

  appMacros = path.join(projectRoot(), "macros.coffee");

  if ((projectRoot != null) && path.existsSync(appMacros)) {
    macros = require(appMacros).macros;
    toCamel = function(str) {
      return str.replace(/^[a-z]/g, function(firstChar) {
        return firstChar.toUpperCase();
      });
    };
    for (name in macros) {
      fn = macros[name];
      className = toCamel(name);
      exports.macros[name] = {
        className: className,
        tokenName: name.toUpperCase(),
        classDef: eval(cs.compile("->\n  class " + className + " extends this.Macro\n    compileNode: `" + fn + "`", {
          bare: true
        }))
      };
    }
    names = (function() {
      var _ref, _results;
      _ref = exports.macros;
      _results = [];
      for (name in _ref) {
        def = _ref[name];
        _results.push(name);
      }
      return _results;
    })();
    if (names.length > 0) {
      console.log("found these macros: " + names);
    } else {
      console.log('no macros found');
    }
  } else {
    console.log('project root not found: no macros loaded');
  }

}).call(this);
