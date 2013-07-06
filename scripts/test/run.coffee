mocha.checkLeaks()
mocha.globals [
  'navigator'  # For Firefox CI test
  'Testem'
]
mocha.run()
