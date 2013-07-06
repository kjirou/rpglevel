(function() {
  (function() {
    var RPGLevel;
    RPGLevel = (function() {
      RPGLevel.VERSION = '0.0.1';

      function RPGLevel() {
        this._exp = 0;
      }

      RPGLevel.prototype.getExp = function() {
        return this._exp;
      };

      return RPGLevel;

    })();
    if (typeof module !== 'undefined') {
      return module.exports = RPGLevel;
    } else {
      return window.RPGLevel = RPGLevel;
    }
  })();

}).call(this);
