gulp = require "gulp"
gutil = require "gulp-util"

rt = require "gulp-react-templates"
rename = require "gulp-rename"

browserify = require "browserify"
coffeeify = require "coffeeify"
uglify = require "gulp-uglify"
source = require "vinyl-source-stream"

less = require "gulp-less"
streamify = require "gulp-streamify"
minify = require "gulp-minify-css"

del = require "del"

zip = require "gulp-zip"
forceDeploy = require "gulp-jsforce-deploy"

express = require "express"
port = 8000

paths =
  scripts:   "./app/scripts"
  styles:    "./app/styles"
  templates: "./app/templates"
  assets:    "./app/assets"
  bower:     "./bower_components"
  force:     "./src"

appName = "MyApp"

debug = (gutil.env.type != 'production')

# Compile React Template file
gulp.task "build:templates", ->
  gulp.src "#{paths.templates}/**/*.rt", base: "#{paths.templates}"
    .pipe rt(modules: "commonjs")
    .pipe gulp.dest "#{paths.scripts}"

# Compile and bundle JS file from CoffeeScript source code
gulp.task "build:scripts", ->
  browserify
    entries: [ "#{paths.scripts}/main.coffee" ]
    extensions: [ ".coffee" ]
  .transform(coffeeify)
  .bundle()
  .pipe source("main.js")
  .pipe gulp.dest "./build/scripts/"
  .pipe streamify uglify()
  .pipe rename(extname: ".min.js")
  .pipe gulp.dest "./build/scripts/"

# Building CSS files from LESS source
gulp.task "build:styles", ->
  gulp.src "#{paths.styles}/main.less"
    .pipe less()
    .pipe gulp.dest "./build/styles/"
    .pipe minify()
    .pipe rename(extname: ".min.css")
    .pipe gulp.dest "./build/styles/"

# Copy all static files in src directory to temporary build directory
gulp.task "build:assets", ->
  gulp.src "#{paths.assets}/**", base: "#{paths.assets}"
    .pipe gulp.dest "./build/"

gulp.task "build", [ "build:templates", "build:scripts", "build:styles", "build:assets" ]

# Cleanup built files
gulp.task "clean", ->
  del [ "#{paths.scripts}/**/*.rt.js", "./build" ]

# Zip all built files as a static resource file
gulp.task "archive:app", ->
  gulp.src "./build/**"
    .pipe zip("#{appName}.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"

# Zip bower installed libralies
gulp.task "archive:lib", ->
  gulp.src "./bower_components/**"
    .pipe zip("#{appName}Lib.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"

# Zip all static resources
gulp.task "archive", [ "archive:lib", "archive:app" ]

###
# Deploying package to Salesforce
###
gulp.task "deploy", [ "archive" ], ->
  gulp.src "./pkg/**/*", base: "."
    .pipe zip("pkg.zip")
    .pipe forceDeploy
      username: process.env.SF_USERNAME
      password: process.env.SF_PASSWORD
      # loginUrl: "https://test.salesforce.com"
      # pollTimeout: 120*1000
      # pollInterval: 10*1000
      # version: '33.0'

# Start HTTP server
gulp.task "serve", [ "build" ], ->
  server = express()
  server.use express.static('./build')
  server.use express.static('./bower_components')
  server.listen port

#
gulp.task "watch:build", ->
  gulp.watch "#{paths.templates}/**", [ "build:templates" ]
  gulp.watch "#{paths.scripts}/**", [ "build:scripts" ]
  gulp.watch "#{paths.styles}/**", [ "build:styles" ]
  gulp.watch "#{paths.assets}/**", [ "build:assets" ]

#
gulp.task "watch:deploy", ->
  gulp.watch "#{paths.force}/**", [ "deploy" ]

#
gulp.task "watch", [ "watch:build", "watch:deploy" ]

#
gulp.task "dev", [ "serve", "watch:build" ]
gulp.task "default", [ "build" ]

