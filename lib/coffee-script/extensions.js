(function() {
  var appMacros, clazz, def, dirname, existsSync, fn, getMacros, join, macros, name, names, normalize, projectRoot, readdirSync, toCamel, _ref;

  readdirSync = require('fs').readdirSync;

  _ref = require('path'), normalize = _ref.normalize, existsSync = _ref.existsSync, join = _ref.join, dirname = _ref.dirname;

  getMacros = function(start) {
    var last, macroFile;
    macroFile = 'macro';
    if (start == null) start = process.cwd();
    if (start === '/' || start === '\\') {
      if (!last) {
        start = __dirname;
        last = true;
      } else {
        return;
      }
    }
    try {
      return require(join(path, macroFile));
    } catch (e) {
      return getMacros(join(start, '..'), last);
    }
  };

  exports.macros = {};

  appMacros = getMacros();

  projectRoot = dirname(appMacros);

  if ((projectRoot != null) && existsSync(appMacros)) {
    macros = require(appMacros).macros;
    toCamel = function(str) {
      return str.replace(/^[a-z]/g, function(firstChar) {
        return firstChar.toUpperCase();
      });
    };
    for (name in macros) {
      fn = macros[name];
      clazz = new Macro;
      clazz.compileNode = function(o) {
        return fn(this.args, {
          compileContext: o,
          projectRoot: projectRoot
        });
      };
      exports.macros[name] = {
        className: toCamel(name),
        tokenName: name.toUpperCase(),
        classDef: clazz
      };
    }
    names = (function() {
      var _ref2, _results;
      _ref2 = exports.macros;
      _results = [];
      for (name in _ref2) {
        def = _ref2[name];
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
