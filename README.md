rpglevel
========

A npm package for creating RPG Level objects.


## Development

### Dependencies

- `node.js` >= `11.0`, e.g. `brew install node`
- `PhantomJS`, e.g. `brew install phantomjs`

```
$ npm install -g grunt-cli testem
```

### Deploy

```
$ git clone git@github.com:kjirou/npm-rpglevel.git
$ cd npm-rpglevel
$ npm install
$ grunt
```

### Build commands

- `grunt` builds all files for development by browser.
- `grunt watch` executes `grunt` each time at updating CoffeeScript files.
- `grunt release` generates JavaScript files for release.

### Testing

- Open [test/index.html](test/index.html)
- Execute `testem`, and open [http://localhost:7357/](http://localhost:7357/)
- `grunt test` is CI test by PhantomJS only.

### For node.js

```
$ grunt node
$ npm test
```
