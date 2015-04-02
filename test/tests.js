var assert = require('assert');

var RPGLevel = require('../index');


describe('rpglevel module', function() {

  context('RPGLevel class', function() {

    it('should be defined as class', function() {
      assert(typeof RPGLevel, 'function');
    });

    it('should construct', function() {
      var rl = new RPGLevel();
      assert(rl instanceof RPGLevel);
    });
  });
});
