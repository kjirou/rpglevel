# rpglevel

[![npm version](https://badge.fury.io/js/rpglevel.svg)](http://badge.fury.io/js/rpglevel)
[![Build Status](https://travis-ci.org/kjirou/npm-rpglevel.svg?branch=master)](https://travis-ci.org/kjirou/npm-rpglevel)

Manage the "level" and the "exp"


## Installation
```
npm install rpglevel
```

Or, you can use in browser through the [browserify](https://github.com/substack/node-browserify).


## Example
```
var RPGLevel = require('rpglevel');

var lv = new RPGLevel();

//
// Define Exp-Table by formula.
//
//   Lv1 = 0
//   Lv2 = 4
//   Lv3 = 6  (Total = 10)
//   Lv4 = 8  (Total = 18)
//   Lv5 = 10 (Total = 28)
//
lv.defineExpTable(function(level){
  return level * 2;
}, {
  maxLevel: 5
});

// You got exps with 2 levels up.
lv.gainExp(10);

// get your level
console.log(lv.getLevel());  // -> 3

// get more information
console.log(lv.getStates());  // -> { level:3, .. }
```


## API Reference

### RPGLevel Class
- `new RPGLevel()`

### RPGLevel Instance
- `defineExpTable(formula, options={})`
  - Set Exp-Table by formula that is  for each levels.
  - Define a fomula like `function(level){ return level * level; }`.
  - Also, a fomula has helper data for calculation in second arg, it is usable as `function(level, data){ .. }`.
- `defineExpTableByArray(necessaryExps)`
  - Set Exp-Table by delta exp list. For example, [0, 2, 4, 8] means what it needs total exps [Lv1=0, Lv2=2, Lv3=6, Lv4=14].
  - For that reason, list[0] is always to contain 0.
- `getMinLevel()`
- `getMaxLevel()`
- `getStartLevel()`
- `getExp()`
- `getTotalNecessaryExp(fromLevel, toLevel)`
- `getNecessaryExpByLevel(level)`
- `getMaxExp()`
- `setExp(exp)`
- `setLevel(level)`
- `resetExp()`
- `gainExp(exp)`
  - That returns a `object` what includes informations about growths in this time.
  - The `object` is like this: `{ beforeLevel: 3, afterLevel: 5, levelDelta: 2, isLevelUp: true ... }`.
- `drainExp(exp)`
  - That reduces your exps.
- `gainLevel(levelUpCount)`
- `drainLevel(levelDownCount)`
- `getStates()`
  - Returns your statuses about level and exps.
- `getLevel()`
- `isMaxLevel()`
