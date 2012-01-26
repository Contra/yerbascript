(function() {
  var appMacros, exists, findParent, join, m, names, normalize, projectRoot, readFileSync, readdirSync, root, rzrRootTest, _ref, _ref2,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ref = require('fs'), readFileSync = _ref.readFileSync, readdirSync = _ref.readdirSync;

  _ref2 = require('path'), exists = _ref2.exists, normalize = _ref2.normalize, join = _ref2.join;

  root = null;

  exports.findParent = findParent = function(dir, predicate) {
    var upDir;
    if (dir === '/') return null;
    if (predicate(dir)) {
      return dir;
    } else {
      upDir = normalize(dir + '/..');
      return findParent(upDir, predicate);
    }
  };

  rzrRootTest = function(dir) {
    return __indexOf.call(readdirSync(dir), 'domain') >= 0;
  };

  exports.projectRoot = projectRoot = function() {
    return root != null ? root : root = findParent(process.cwd(), rzrRootTest);
  };

  exports.macros = [];

  appMacros = join(projectRoot(), "macros.coffee");

  if (require.resolve(appMacros)) {
    names = (function() {
      var _i, _len, _ref3, _results;
      _ref3 = exports.macros;
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        m = _ref3[_i];
        _results.push(m.name);
      }
      return _results;
    })();
    if (names != null) {
      console.log("found these macros: " + names);
    } else {
      console.log('no macros found');
    }
  } else {
    console.log('project root not found');
  }

}).call(this);
