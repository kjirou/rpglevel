if typeof require isnt 'undefined'
  expect = require 'expect.js'
  RPGLevel = require 'RPGLevel'
else
  expect = @expect
  RPGLevel = @RPGLevel


describe('Class Properties ::', ->
    it('VERSION', ->
      expect(RPGLevel.VERSION).to.match(/^\d+\.\d+.\d+(?:\.\d+)?$/)
    )
)


describe('Instance Properties ::', ->
    it('getExp', ->
      lv = new RPGLevel
      lv._exp = 10
      expect(lv.getExp()).to.be(lv._exp)
    )
)
