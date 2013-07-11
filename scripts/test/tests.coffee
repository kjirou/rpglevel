if typeof require isnt 'undefined'
  expect = require 'expect.js'
  sinon = require 'sinon'
  RPGLevel = require './rpglevel.js'
else
  expect = @expect
  sinon = @sinon
  RPGLevel = @RPGLevel


describe('RPGLevel Class ::', ->
  it('VERSION', ->
    expect(RPGLevel.VERSION).to.match(/^\d+\.\d+.\d+(?:\.\d+)?$/)
  )
)


describe('RPGLevel Instance ::', ->
  it('Define Exp-Table directly', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 3])
    expect(lv._necessaryExps[2]).to.be(2)
  )

  it('Define invalid Exp-Table directly', ->
    lv = new RPGLevel
    expect(->
      lv.defineExpTable([1, 2, 3])
    ).throwException((e) ->
      expect(e).to.be.a(RPGLevel.InvalidArgsError)
    )
  )

  it('Generate Exp-Table by formula', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level * 2)
    expect(lv._necessaryExps[1]).to.be(4)
    expect(lv._necessaryExps[2]).to.be(6)

    # Use options
    lv = new RPGLevel
    lv.defineExpTable(((level) -> level), {
      startLevel: 50
      maxLevel: 55
    })
    expect(lv._necessaryExps[49]).to.be(0)
    expect(lv.getMaxLevel()).to.be(55)

    # Use formula's sub data
    lv = new RPGLevel
    lv.defineExpTable((level, data) ->
      expect(data.minLevel).to.be(1)
      expect(data.startLevel).to.be(2)
      expect(data.maxLevel).to.be(3)
      1
    , {
      startLevel: 2
      maxLevel: 3
    })
  )

  it('getMinLevel', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level)
    expect(lv.getMinLevel()).to.be(1)
  )

  it('getMaxLevel', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level)
    expect(lv.getMaxLevel()).to.be(99)

    lv = new RPGLevel
    lv.defineExpTable(((level) -> level), maxLevel: 10)
    expect(lv.getMaxLevel()).to.be(10)
  )

  it('getStartLevel', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level)
    expect(lv.getStartLevel()).to.be(1)

    lv = new RPGLevel
    lv.defineExpTable(((level) -> level), startLevel: 5)
    expect(lv.getStartLevel()).to.be(5)
  )

  it('getNecessaryExpByLevel', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16])
    expect(lv.getNecessaryExpByLevel(1)).to.be(0)
    expect(lv.getNecessaryExpByLevel(4)).to.be(4)
  )

  it('getTotalNecessaryExp / getMaxExp', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16])
    expect(lv.getTotalNecessaryExp(2, 4)).to.be(2 + 4)
    expect(lv.getMaxExp()).to.be(1 + 2 + 4 + 8 + 16)
  )

  it('setExp', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16])
    lv.setExp(10)
    expect(lv.getExp()).to.be(10)

    # Cleaning caches
    lv.gainExp(1)
    expect(lv._hasCachedLevelStatuses()).to.ok()
    lv.setExp(10)
    expect(lv._hasCachedLevelStatuses()).to.not.ok()
  )

  it('resetExp', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16])
    lv.gainExp(10)
    lv.resetExp()
    expect(lv.getExp()).to.be(0)

    # Equals to new born instance
    lv2 = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16])
    expect(lv.getExp()).to.be(lv2.getExp())
  )

  it('gainExp / getExp', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level)
    lv.gainExp(100)
    expect(lv.getExp()).to.be(100)
  )

  it('Gained float Exp is floored', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4])
    lv.gainExp(1.6)
    expect(lv.getExp()).to.be(1)
  )

  it('gainExp returns level-up infos', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 3, 3, 3, 3, 3])

    lv.gainExp(1)
    res = lv.gainExp(6)
    expect(res.isLevelUp).to.be(true)
    expect(res.isLevelDown).to.be(false)
    expect(res.beforeExp).to.be(1)
    expect(res.afterExp).to.be(7)
    expect(res.expDelta).to.be(6)
    expect(res.beforeLevel).to.be(1)
    expect(res.afterLevel).to.be(3)
    expect(res.levelDelta).to.be(2)

    expect(lv.gainExp(1).isLevelUp).to.be(false)
    expect(lv.gainExp(1).isLevelUp).to.be(true)
  )

  it('Exp is not over max Exp / isMaxLevel', ->
    lv = new RPGLevel
    lv.defineExpTable((level) -> level)
    expect(lv.isMaxLevel()).to.be(false)
    lv.gainExp(9999999999)
    expect(lv.getExp()).to.be(lv.getMaxExp())
    expect(lv.getLevel()).to.be(lv.getMaxLevel())
    expect(lv.isMaxLevel()).to.be(true)

    # Threshold check
    res = lv.gainExp(1)
    expect(res.expDelta).to.be(0)
    expect(res.levelDelta).to.be(0)
  )

  it('drainExp', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 5, 10, 15, 20])
    lv.gainExp(35)

    expect(lv.getLevel()).to.be(4)
    expect(lv.drainExp(5).levelDelta).to.be(0)
    expect(lv.drainExp(1).levelDelta).to.be(-1)
    expect(lv.drainExp(1).levelDelta).to.be(0)
    expect(lv.drainExp(24).levelDelta).to.be(-2)
    expect(lv.getLevel()).to.be(1)
  )

  it('Exp is not under 0', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1])
    lv.drainExp(9999999999)
    expect(lv.getExp()).to.be(0)
    expect(lv.getLevel()).to.be(lv.getMinLevel())
  )

  it('getStatuses / getLevel', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16, 32])
    exp = 8
    lv.gainExp(exp)
    stats = lv.getStatuses()

    expect(stats).to.be.a('object')
    expect(stats.level).to.be(4)
    expect(stats.necessaryExpForNext).to.be(8)
    expect(stats.gainedExpForNext).to.be(exp - (1 + 2 + 4))
    expect(stats.lackExpForNext).to.be(8 - stats.gainedExpForNext)

    expect(lv.getLevel()).to.be(4)
  )

  it('Using getStatuses cache', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16, 32])
    lv.gainExp(15)

    spy = sinon.spy(lv, '_hasCachedLevelStatuses')
    lv.getStatuses()
    lv.getStatuses()
    expect(spy.returnValues).to.eql([true, true])
    spy.restore()

    spy = sinon.spy(lv, '_hasCachedLevelStatuses')
    lv.gainExp(1)
    lv.getStatuses()
    expect(spy.returnValues).to.eql([true, false, true])
    spy.restore()
  )

  it('gainLevel', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16, 32])
    lv.gainLevel(1)
    expect(lv.getExp()).to.be(1)
    lv.gainLevel(2)
    expect(lv.getExp()).to.be(1 + 2 + 4)
  )

  it('drainLevel', ->
    lv = new RPGLevel
    lv.defineExpTable([0, 1, 2, 4, 8, 16, 32])
    lv.gainLevel(4)
    expect(lv.getExp()).to.be(1 + 2 + 4 + 8)
    lv.drainLevel(1)
    expect(lv.getExp()).to.be(1 + 2 + 4 + 8 - 1)

    lv.drainLevel(2)
    expect(lv.getExp()).to.be(1 + 2 - 1)
  )
)


describe('Exp-Tables Management ::', ->

  describe('Common behaviors ::', ->
    it('Not found key', ->
      lv = new RPGLevel
      expect(->
        lv.defineExpTable('notfoundkey')
      ).throwException((e) ->
        expect(e).to.be.a(RPGLevel.InvalidArgsError)
      )
    )
  )

  describe('Preset Exp-Tables ::', ->
    it('Use a preset "wiz_like" table', ->
      lv = new RPGLevel
      lv.defineExpTable('wiz_like')
      expect(lv.getNecessaryExpByLevel(2)).to.be(1000)
      expect(lv.getNecessaryExpByLevel(3)).to.be(724)
      expect(lv.getNecessaryExpByLevel(14)).to.be(289712)
      expect(lv.getNecessaryExpByLevel(99)).to.be(289712)
    )
  )

  describe('Custom Exp-Tables ::', ->

    afterEach(->
      RPGLevel.cleanExpTableDefinitions()
    )

    it('cleanExpTableDefinitions', ->
      expect(RPGLevel._expTableDefinitions).to.eql({})
      RPGLevel.registerExpTableDefinition('foo', [0, 1, 2, 4])
      RPGLevel.registerExpTableDefinition('bar', [0, 1, 2, 4])
      expect('foo' of RPGLevel._expTableDefinitions).to.ok()
      expect('bar' of RPGLevel._expTableDefinitions).to.ok()
      RPGLevel.cleanExpTableDefinitions()
      expect(RPGLevel._expTableDefinitions).to.eql({})
    )

    it('Throw a error at registering duplicated key', ->
      RPGLevel.registerExpTableDefinition('foo', [0, 1, 2, 4])
      expect(->
        RPGLevel.registerExpTableDefinition('foo', [0, 1, 2, 4])
      ).throwException((e) ->
        expect(e).to.be.a(RPGLevel.InvalidArgsError)
      )
    )

    it('registerExpTableDefinition', ->
      RPGLevel.registerExpTableDefinition('foo', [0, 1, 2, 4])
      RPGLevel.registerExpTableDefinition('bar', (level) ->
        level * level
      , {
        maxLevel: 3
      })

      lv = new RPGLevel
      lv.defineExpTable('foo')
      expect(lv.getMaxExp()).to.be(1 + 2 + 4)

      lv = new RPGLevel
      lv.defineExpTable('bar')
      expect(lv.getMaxExp()).to.be(2 * 2 + 3 * 3)
    )
  )
)
