module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-testem'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    constants:
      coffee:
        src: [
          'scripts/src/rpglevel.coffee'
        ]
        test: [
          'scripts/test/setup.coffee'
          'scripts/test/tests.coffee'
          'scripts/test/run.coffee'
        ]
      js:
        test: [
          'node_modules/mocha/mocha.js'
          'node_modules/expect.js/expect.js'
          'node_modules/sinon/pkg/sinon.js'
        ]
      css:
        test: [
          'node_modules/mocha/mocha.css'
        ]
      builded:
        js:
          src: 'test/assets/build/_src.js'
          test: 'test/assets/build/_test.js'
          all: 'test/assets/build/all.js'
          minified: 'rpglevel.min.js'
          notminified: 'rpglevel.js'
        css:
          all: 'test/assets/build/all.css'

    clean: ['test/assets/build']

    coffee:
      development:
        options:
          join: true
          bare: false
        files:
          '<%= constants.builded.js.src %>': [
            '<%= constants.coffee.src %>'
          ]
          '<%= constants.builded.js.test %>': [
            '<%= constants.coffee.test %>'
          ]
      production:
        options:
          join: true
          bare: false
        files:
          '<%= constants.builded.js.notminified %>': [
            '<%= constants.coffee.src %>'
          ]

    concat:
      development_js:
        options:
          separator: ';\n'
        src: [
          '<%= constants.builded.js.src %>'
          '<%= constants.js.test %>'
          '<%= constants.builded.js.test %>'
        ]
        dest: '<%= constants.builded.js.all %>'
      development_css:
        options:
          separator: '\n'
        src: [
          '<%= constants.css.test %>'
        ]
        dest: '<%= constants.builded.css.all %>'

    uglify:
      production:
        files:
          '<%= constants.builded.js.minified %>': '<%= constants.builded.js.notminified %>'

    watch:
      coffee:
        files: [
          '<%= constants.coffee.src %>'
          '<%= constants.coffee.test %>'
        ]
        tasks: ['build']

    testem:
      options:
        launch_in_ci: [
          'phantomjs'
        ]
      main:
        src: [
          'test/index.html'
        ]
        dest: 'log/tests.tap'
      # Waring: Chrome can't finish tests occasionally.
      # Ref) https://github.com/airportyh/testem/issues/240
      all_launchers:
        options: {
          launch_in_ci: [
            'phantomjs'
            'firefox'
            'safari'
            'chrome'
          ]
        }
        src: [
          'test/index.html'
        ]
        dest: 'log/tests.tap'
      travis:
        options: {
          launch_in_ci: [
            'phantomjs'
          ]
        }
        src: [
          'test/index.html'
        ]

    replace:
      version:
        src: [
          'package.json'
          'scripts/src/rpglevel.coffee'
        ]
        overwrite: true
        replacements: [
          from: /(['"])0\.0\.X(['"])/
          to: '$10.0.2$2'
        ]

  grunt.registerTask 'build', [
    'clean'
    'coffee:development'
    'concat:development_js'
    'concat:development_css'
  ]

  grunt.registerTask 'travis', [
    'build'
    'testem:travis'
  ]

  grunt.registerTask 'release', [
    'replace:version'
    'coffee:production'
    'uglify:production'
  ]

  # Aliases
  grunt.registerTask 'default', ['build']
  grunt.registerTask 'test', ['testem:main']
