var _ = require('lodash');


var RPGLevel = function RPGLevel() {

  this._exp = 0;

  // This is necessary-Exp delta list for Level-Up.
  // For example, [0, 2, 4, 8] means what
  //   it needs total Exps [Lv1=0, Lv2=2, Lv3=6, Lv4=14].
  // For that reason, [0] is always to contain 0.
  this._necessaryExps = [];

  this._minLevel = 1;

  this._cachedLevels = null;
};

RPGLevel.prototype.defineExpTable = function defineExpTable(formula, options) {
  this._necessaryExps = this._generateNecessaryExps(formula, options);
};

/**
 * @param {Function} formula
 * @param {Object|undefined} options
 * @return {Array}
 */
RPGLevel.prototype._generateNecessaryExps = function _generateNecessaryExps(formula, options) {
  options = _.assign({
    startLevel: 1,
    maxLevel: 99
  }, options || {});

  var exps = [];
  var previousExp = 0;
  var previousTotalExp = 0;
  var memo = {};

  return _.range(this._minLevel, options.maxLevel).map(function(level) {
    var exp;

    if (level <= options.startLevel) {
      exp = 0;
    } else {
      exp = formula(level, {
        self: this,
        minLevel: this._minLevel,
        startLevel: options.startLevel,
        maxLevel: options.maxLevel,
        levelDelta: options.maxLevel - options.startLevel,
        exps: exps,
        previousExp: previousExp,
        previousTotalExp: previousTotalExp,
        memo: memo
      })
      previousExp = exp;
      previousTotalExp += exp;
    }

    exps.push(exp);
    return exp;
  });
};

RPGLevel.prototype.getMinLevel = function getMinLevel() {
  return this._minLevel;
};

RPGLevel.prototype.getMaxLevel = function getMaxLevel() {
  return this._necessaryExps.length;
};

RPGLevel.prototype._getIndexByLevel = function _getIndexByLevel(level) {
  return level - 1;
};

RPGLevel.prototype._getLevelByIndex = function _getLevelByIndex(index) {
  return Number(index) + 1;
};

RPGLevel.prototype.getStartIndex = function getStartIndex() {
  for (var i = 0; i < this._necessaryExps.length; i++) {
    if (this._necessaryExps[i] > 0) {
      return Number(i) - 1;
    }
  }
};

RPGLevel.prototype.getStartLevel = function getStartLevel() {
  return this._getLevelByIndex(this.getStartIndex());
};

RPGLevel.prototype.getExp = function getExp() {
  return this._exp;
};

RPGLevel.prototype.getTotalNecessaryExp = function getTotalNecessaryExp(fromLevel, toLevel) {
  var self = this;
  return _.reduce(_.range(fromLevel, toLevel), function(total, level) {
    var idx = self._getIndexByLevel(level);
    return total + self._necessaryExps[idx];
  }, 0);
};

RPGLevel.prototype.getNecessaryExpByLevel = function getNecessaryExpByLevel(level) {
  return this._necessaryExps[this._getIndexByLevel(level)];
};

RPGLevel.prototype.getMaxExp = function getMaxExp() {
  return this.getTotalNecessaryExp(this.getMinLevel(), this.getMaxLevel());
};

RPGLevel.prototype._cleanCaches = function _cleanCaches() {
  this._cachedLevels = null;
};

RPGLevel.prototype.setExp = function setExp(exp) {
  this._exp = parseInt(exp, 10);
  this._cleanCaches();
};

RPGLevel.prototype.resetExp = function resetExp() {
  this.setExp(0);
};

RPGLevel.prototype._hasCachedLevels = function _hasCachedLevels() {
  return !!this._cachedLevels;
};

RPGLevel.prototype.getStates = function getStates() {
  var self = this;

  if (this._hasCachedLevels) {
    return _.cloneDeep(this._cachedLevels);
  }

  var myLevel = 0;
  var totalNecessaryExp = 0;
  var necessaryExpForNext = 0;
  var gainedExpForNext = 0;

  this._necessaryExps.every(function(necessaryExp, idx) {
    var level = self._getLevelByIndex(idx);
    totalNecessaryExp += necessaryExp;
    if (self.getExp() >= totalNecessaryExp) {
      myLevel = level;
      return true;
    } else {
      necessaryExpForNext = necessaryExp;
      gainedExpForNext = self.getExp() - (totalNecessaryExp - necessaryExp);
      return false;
    }
  });

  var states = {
    level: myLevel,
    necessaryExpForNext: necessaryExpForNext,
    gainedExpForNext: gainedExpForNext,
    lackExpForNext: necessaryExpForNext - gainedExpForNext
  };

  this._cachedLevels = _.cloneDeep(states);

  return states;
};

RPGLevel.prototype.getLevel = function getLevel() {
  return this.getStates().level;
};

RPGLevel.prototype.isMaxLevel = function isMaxLevel() {
  return this.getLevel() === this.getMaxLevel();
};

RPGLevel.prototype._updateExp = function _updateExp(exp) {
  var beforeLevel = this.getLevel();

  var nextExp = this.getExp() + exp;
  if (nextExp > this.getMaxExp()) {
    nextExp = this.getMaxExp();
  } else if (nextExp < 0) {
    nextExp = 0;
  }
  this.setExp(nextExp);

  var afterLevel = this.getLevel();

  return {
    beforeLevel: beforeLevel,
    afterLevel: afterLevel
  };
};

RPGLevel.prototype._createExpUpdateResults = function _createExpUpdateResults(
  beforeExp, afterExp, beforeLevel, afterLevel
) {
  return {
    beforeExp: beforeExp,
    afterExp: afterExp,
    expDelta: afterExp + beforeExp,
    beforeLevel: beforeLevel,
    afterLevel: afterLevel,
    levelDelta: afterLevel - beforeLevel,
    isLevelUp: afterLevel > beforeLevel,
    isLevelDown: afterLevel < beforeLevel
  };
};

RPGLevel.prototype.gainExp = function gainExp(exp) {
  var beforeExp = this.getExp();
  var updated = this._updateExp(exp);
  return this._createExpUpdateResults(
    beforeExp, this.getExp(), updated.beforeLevel, updated.afterLevel);
};

RPGLevel.prototype.drainExp = function drainExp(exp) {
  var beforeExp = this.getExp();
  var updated = this._updateExp(-exp);
  return this._createExpUpdateResults(
    beforeExp, this.getExp(), updated.beforeLevel, updated.afterLevel);
};

RPGLevel.prototype.gainLevel = function gainLevel(levelUpCount) {
  var fromLevel = this.getLevel();
  var toLevel = fromLevel + levelUpCount;
  if (toLevel > this.getMaxLevel()) {
    toLevel = this.getMaxLevel();
  }
  // It is always adjusting like the following:
  //
  //   Lv=1, Current/Next 3/5
  //     (+1 Level Up)
  //   Lv=2, Current/Next 0/10 (Ignores remained 3 exp)
  var deltaExp = this.getTotalNecessaryExp(this.getMinLevel(), toLevel) - this.getExp();
  return this.gainExp(deltaExp);
};

RPGLevel.prototype.drainLevel = function drainLevel(levelDownCount) {
  var toLevel = this.getLevel() + levelDownCount;
  if (toLevel < this.getMinLevel()) {
    toLevel = this.getMinLevel();
  }
  // It is always adjusting like the following:
  //
  //   Lv=2, Current/Next 3/10
  //     (-1 Level Down)
  //   Lv=1, Current/Next 4/5 (Always (max-1) exp)
  var deltaExp = this.getExp() - this.getTotalNecessaryExp(this.getMinLevel(), toLevel) + 1;
  return this.drainExp(deltaExp);
};


module.exports = RPGLevel;
