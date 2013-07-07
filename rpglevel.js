(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  (function() {
    var RPGLevel;
    RPGLevel = (function() {
      var InvalidArgsError;

      RPGLevel.VERSION = '0.9.0';

      RPGLevel.InvalidArgsError = InvalidArgsError = (function(_super) {
        __extends(InvalidArgsError, _super);

        function InvalidArgsError(message) {
          this.message = message;
          this.name = 'InvalidArgsError';
          InvalidArgsError.__super__.constructor.apply(this, arguments);
        }

        return InvalidArgsError;

      })(Error);

      function RPGLevel() {
        this._exp = 0;
        this._necessaryExps = [];
        this._minLevel = 1;
        this._cachedLevelStatuses = null;
      }

      RPGLevel.prototype._extend = function(obj, props) {
        var k, v;
        for (k in props) {
          v = props[k];
          obj[k] = v;
        }
        return obj;
      };

      RPGLevel.prototype.defineExpTable = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        if (args[0] instanceof Array) {
          this._necessaryExps = args[0];
        } else {
          this._necessaryExps = this._generateNecessaryExps(args[0], args[1]);
        }
        if (this._necessaryExps[0] !== 0) {
          throw new InvalidArgsError("Invalid Exp-Table.");
        }
      };

      RPGLevel.prototype._generateNecessaryExps = function(formula, options) {
        var level, opts;
        if (options == null) {
          options = {};
        }
        opts = this._extend({
          startLevel: 1,
          maxLevel: 99
        }, options);
        return this._necessaryExps = (function() {
          var _i, _ref, _ref1, _results;
          _results = [];
          for (level = _i = _ref = this._minLevel, _ref1 = opts.maxLevel; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; level = _ref <= _ref1 ? ++_i : --_i) {
            if (level <= opts.startLevel) {
              _results.push(0);
            } else {
              _results.push(formula(level, {
                minLevel: this._minLevel,
                startLevel: opts.startLevel,
                maxLevel: opts.maxLevel
              }));
            }
          }
          return _results;
        }).call(this);
      };

      RPGLevel.prototype.getMinLevel = function() {
        return this._minLevel;
      };

      RPGLevel.prototype.getMaxLevel = function() {
        return this._necessaryExps.length;
      };

      RPGLevel.prototype.getStartLevel = function() {
        var i, v, _ref;
        _ref = this._necessaryExps;
        for (i in _ref) {
          v = _ref[i];
          if (v > 0) {
            return parseInt(i, 10);
          }
        }
      };

      RPGLevel.prototype._getIndexByLevel = function(level) {
        return level - 1;
      };

      RPGLevel.prototype._getLevelByIndex = function(index) {
        return parseInt(index, 10) + 1;
      };

      RPGLevel.prototype.getExp = function() {
        return this._exp;
      };

      RPGLevel.prototype.getTotalNecessaryExp = function(fromLevel, toLevel) {
        var idx, level, total, _i, _ref;
        total = 0;
        for (level = _i = _ref = fromLevel + 1; _ref <= toLevel ? _i <= toLevel : _i >= toLevel; level = _ref <= toLevel ? ++_i : --_i) {
          idx = this._getIndexByLevel(level);
          total += this._necessaryExps[idx];
        }
        return total;
      };

      RPGLevel.prototype.getNecessaryExpByLevel = function(level) {
        return this._necessaryExps[this._getIndexByLevel(level)];
      };

      RPGLevel.prototype.getMaxExp = function() {
        return this.getTotalNecessaryExp(this.getMinLevel(), this.getMaxLevel());
      };

      RPGLevel.prototype._updateExp = function(exp) {
        var afterLevel, beforeLevel;
        beforeLevel = this.getLevel();
        this._exp = this._exp + exp;
        if (this._exp > this.getMaxExp()) {
          this._exp = this.getMaxExp();
        } else if (this._exp < 0) {
          this._exp = 0;
        }
        this._cachedLevelStatuses = null;
        afterLevel = this.getLevel();
        return [beforeLevel, afterLevel];
      };

      RPGLevel.prototype.gainExp = function(exp) {
        var afterLevel, beforeLevel, _ref;
        _ref = this._updateExp(exp), beforeLevel = _ref[0], afterLevel = _ref[1];
        return afterLevel - beforeLevel;
      };

      RPGLevel.prototype.drainExp = function(exp) {
        var afterLevel, beforeLevel, _ref;
        _ref = this._updateExp(-exp), beforeLevel = _ref[0], afterLevel = _ref[1];
        return afterLevel - beforeLevel;
      };

      RPGLevel.prototype.gainLevel = function(levelUpCount) {
        var delta, from, to;
        from = this.getLevel();
        to = from + levelUpCount;
        if (to > this.getMaxLevel()) {
          to = this.getMaxLevel();
        }
        delta = this.getTotalNecessaryExp(this.getMinLevel(), to) - this.getExp();
        return this.gainExp(delta);
      };

      RPGLevel.prototype.drainLevel = function(levelDownCount) {
        var delta, to;
        to = this.getLevel() - levelDownCount;
        if (to < 0) {
          to = 0;
        }
        delta = this.getExp() - this.getTotalNecessaryExp(this.getMinLevel(), to + 1);
        return this.drainExp(delta + 1);
      };

      RPGLevel.prototype._hasCachedLevelStatuses = function() {
        return this._cachedLevelStatuses !== null;
      };

      RPGLevel.prototype.getStatuses = function() {
        var exp, gainedExpForNext, idx, level, myLevel, necessaryExpForNext, statuses, totalNecessaryExp, _ref;
        if (this._hasCachedLevelStatuses()) {
          return this._extend({}, this._cachedLevelStatuses);
        }
        myLevel = 0;
        totalNecessaryExp = 0;
        necessaryExpForNext = 0;
        gainedExpForNext = 0;
        _ref = this._necessaryExps;
        for (idx in _ref) {
          exp = _ref[idx];
          level = this._getLevelByIndex(idx);
          totalNecessaryExp += exp;
          if (this._exp >= totalNecessaryExp) {
            myLevel = level;
          } else {
            necessaryExpForNext = exp;
            gainedExpForNext = this._exp - (totalNecessaryExp - exp);
            break;
          }
        }
        statuses = {
          level: myLevel,
          necessaryExpForNext: necessaryExpForNext,
          gainedExpForNext: gainedExpForNext,
          lackExpForNext: necessaryExpForNext - gainedExpForNext
        };
        this._cachedLevelStatuses = this._extend({}, statuses);
        return statuses;
      };

      RPGLevel.prototype.getLevel = function() {
        return this.getStatuses().level;
      };

      RPGLevel.prototype.isMaxLevel = function() {
        return this.getLevel() === this.getMaxLevel();
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
