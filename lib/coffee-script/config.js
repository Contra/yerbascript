(function() {
  var findParent, join, normalize, projectRoot, readdirSync, root, rzrRootTest, _ref,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  readdirSync = require('fs').readdirSync;

  _ref = require('path'), normalize = _ref.normalize, join = _ref.join;

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

  if (projectRoot()) {
    exports.support = require(join(projectRoot(), "support/support.coffee"));
  }

}).call(this);
