var assert = require('assert');
var sinon = require('sinon');

var RPGLevel = require('../index');


describe('rpglevel module', function() {

  context('RPGLevel class', function() {

    it('should be defined as class', function() {
      assert(typeof RPGLevel, 'function');
    });

    it('should construct', function() {
      var lv = new RPGLevel();
      assert(lv instanceof RPGLevel);
    });
  });

  context('RPGLevel instance', function() {

    it('defineExpTable', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) {
        return (level - 1) * 2;
      }, {
        maxLevel: 5
      });
      assert.deepEqual(lv._necessaryExps, [ 0, 2, 4, 6, 8 ]);
    });

    it('use sub information in defineExpTable', function() {
      var lv = new RPGLevel();
      var formula = function(level, data) { return level ; };
      var spy = sinon.spy(formula);
      lv.defineExpTable(spy);
      assert.strictEqual(spy.firstCall.args[0], 2);  // no calculation if level equals startLevel
      assert.strictEqual(spy.firstCall.args[1].minLevel, 1);
      assert.strictEqual(spy.firstCall.args[1].startLevel, 1);
      assert.strictEqual(spy.firstCall.args[1].maxLevel, 99);
      assert.deepEqual(spy.firstCall.args[1].exps, [0]);
      assert.strictEqual(spy.firstCall.args[1].previousExp, 0);
      assert.strictEqual(spy.firstCall.args[1].previousTotalExp, 0);
      assert.strictEqual(spy.secondCall.args[0], 3);
      assert.strictEqual(spy.secondCall.args[1].minLevel, 1);
      assert.strictEqual(spy.secondCall.args[1].startLevel, 1);
      assert.strictEqual(spy.secondCall.args[1].maxLevel, 99);
      assert.deepEqual(spy.secondCall.args[1].exps, [0, 2]);
      assert.strictEqual(spy.secondCall.args[1].previousExp, 2);
      assert.strictEqual(spy.secondCall.args[1].previousTotalExp, 2);
    });

    it('options effects sub information', function() {
      var lv = new RPGLevel();
      var formula = function(level, data) { return level ; };
      var spy = sinon.spy(formula);
      lv.defineExpTable(spy, {
        startLevel: 3,
        maxLevel: 50
      });
      assert.strictEqual(spy.firstCall.args[0], 4);
      assert.strictEqual(spy.firstCall.args[1].startLevel, 3);
      assert.strictEqual(spy.firstCall.args[1].maxLevel, 50);
    });

    it('getStartLevel', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function() { return 1; });
      assert.strictEqual(lv.getStartLevel(), 1);

      var lv = new RPGLevel();
      lv.defineExpTable(function() { return 1; }, {
        startLevel: 3
      });
      assert.strictEqual(lv.getStartLevel(), 3);
    });

    it('getTotalNecessaryExp', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; }, {
        maxLevel: 5
      });
      assert.strictEqual(lv.getTotalNecessaryExp(1, 5), 2 + 3 + 4 + 5);
      assert.strictEqual(lv.getTotalNecessaryExp(2, 2), 2);
      assert.strictEqual(lv.getTotalNecessaryExp(3, 4), 3 + 4);

      assert.throws(function() {
        lv.getTotalNecessaryExp(0, 5);
      });
      assert.throws(function() {
        lv.getTotalNecessaryExp(1, 6);
      });
      assert.throws(function() {
        lv.getTotalNecessaryExp(3, 2);
      });
    });

    it('setLevel', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; });

      lv.setLevel(1);
      assert.strictEqual(lv.getLevel(), 1);
      assert.strictEqual(lv.getExp(), 0);

      lv.setLevel(3);
      assert.strictEqual(lv.getLevel(), 3);
      assert.strictEqual(lv.getExp(), 2 + 3);

      lv.setLevel(5);
      assert.strictEqual(lv.getLevel(), 5);
      assert.strictEqual(lv.getExp(), 2 + 3 + 4 + 5);
    });

    it('gain exp and look level states', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; }, {
        maxLevel: 5
      });

      var result;

      result = lv.gainExp(8);
      assert.deepEqual(lv.getStates(), {
        level: 3,
        necessaryExpForNext: 4,
        gainedExpForNext: 3,  // 8 - (2 + 3)
        lackExpForNext: 1  // 4 - 3
      });
      assert.strictEqual(lv.getLevel(), 3);
      assert(lv.isMaxLevel() === false);
      assert.deepEqual(result, {
        beforeExp: 0,
        afterExp: 8,
        expDelta: 8,
        beforeLevel: 1,
        afterLevel: 3,
        levelDelta: 2,
        isLevelUp: true,
        isLevelDown: false
      });

      result = lv.gainExp(2);
      assert.deepEqual(lv.getStates(), {
        level: 4,
        necessaryExpForNext: 5,
        gainedExpForNext: 1,
        lackExpForNext: 4
      });
      assert.deepEqual(result, {
        beforeExp: 8,
        afterExp: 10,
        expDelta: 2,
        beforeLevel: 3,
        afterLevel: 4,
        levelDelta: 1,
        isLevelUp: true,
        isLevelDown: false
      });

      result = lv.gainExp(99);
      assert.deepEqual(lv.getStates(), {
        level: 5,
        necessaryExpForNext: 0,
        gainedExpForNext: 0,
        lackExpForNext: 0
      });
      assert(lv.isMaxLevel());
      assert.deepEqual(result, {
        beforeExp: 10,
        afterExp: 14,
        expDelta: 4,
        beforeLevel: 4,
        afterLevel: 5,
        levelDelta: 1,
        isLevelUp: true,
        isLevelDown: false
      });
    });

    it('drainExp', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; }, {
        maxLevel: 5
      });
      lv.gainExp(10);

      var result;

      result = lv.drainExp(1);
      assert.deepEqual(lv.getStates(), {
        level: 4,
        necessaryExpForNext: 5,
        gainedExpForNext: 0,
        lackExpForNext: 5
      });
      assert.deepEqual(result, {
        beforeExp: 10,
        afterExp: 9,
        expDelta: -1,
        beforeLevel: 4,
        afterLevel: 4,
        levelDelta: 0,
        isLevelUp: false,
        isLevelDown: false
      });

      result = lv.drainExp(1);
      assert.deepEqual(lv.getStates(), {
        level: 3,
        necessaryExpForNext: 4,
        gainedExpForNext: 3,
        lackExpForNext: 1
      });
      assert.deepEqual(result, {
        beforeExp: 9,
        afterExp: 8,
        expDelta: -1,
        beforeLevel: 4,
        afterLevel: 3,
        levelDelta: -1,
        isLevelUp: false,
        isLevelDown: true
      });

      result = lv.drainExp(99);
      assert.deepEqual(lv.getStates(), {
        level: 1,
        necessaryExpForNext: 2,
        gainedExpForNext: 0,
        lackExpForNext: 2
      });
      assert.deepEqual(result, {
        beforeExp: 8,
        afterExp: 0,
        expDelta: -8,
        beforeLevel: 3,
        afterLevel: 1,
        levelDelta: -2,
        isLevelUp: false,
        isLevelDown: true
      });
    });

    it('gainLevel', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; }, {
        maxLevel: 5
      });

      var result;

      result = lv.gainLevel(2);
      assert.deepEqual(lv.getStates(), {
        level: 3,
        necessaryExpForNext: 4,
        gainedExpForNext: 0,
        lackExpForNext: 4
      });
      assert.deepEqual(result, {
        beforeExp: 0,
        afterExp: 5,
        expDelta: 5,
        beforeLevel: 1,
        afterLevel: 3,
        levelDelta: 2,
        isLevelUp: true,
        isLevelDown: false
      });

      lv.gainLevel(99);
      assert.deepEqual(lv.getStates(), {
        level: 5,
        necessaryExpForNext: 0,
        gainedExpForNext: 0,
        lackExpForNext: 0
      });
    });

    it('drainLevel', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; }, {
        maxLevel: 5
      });
      lv.gainExp(99);

      var result;

      result = lv.drainLevel(2);
      assert.deepEqual(lv.getStates(), {
        level: 3,
        necessaryExpForNext: 4,
        gainedExpForNext: 3,
        lackExpForNext: 1
      });
      assert.deepEqual(result, {
        beforeExp: 14,
        afterExp: 8,
        expDelta: -6,
        beforeLevel: 5,
        afterLevel: 3,
        levelDelta: -2,
        isLevelUp: false,
        isLevelDown: true
      });

      lv.drainLevel(99);
      assert.deepEqual(lv.getStates(), {
        level: 1,
        necessaryExpForNext: 2,
        gainedExpForNext: 1,
        lackExpForNext: 1
      });
    });
  });

  context('states caching', function() {

    it('should overwrite _cachedStates for each gainExp execution', function() {
      var lv = new RPGLevel();
      lv.defineExpTable(function(level) { return level; });
      assert.strictEqual(lv._cachedStates, null);

      lv.gainExp(1);
      assert.notStrictEqual(lv._cachedStates, null);

      var cachedStates = lv._cachedStates;
      lv.getStates();
      assert.strictEqual(lv._cachedStates, cachedStates);

      lv.gainExp(1);
      assert.notStrictEqual(lv._cachedStates, cachedStates);
    });
  });
});
