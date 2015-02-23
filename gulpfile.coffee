gulp = require "gulp"
gutil = require "gulp-util"
plumber = require "gulp-plumber"
changed = require "gulp-changed"

rt = require "gulp-react-templates"
rename = require "gulp-rename"

coffee = require "gulp-coffee"
cjsx = require "gulp-cjsx"
babel = require "gulp-babel"

browserify = require "browserify"
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

#
paths =
  src:
    assets:    "./app/assets"
    scripts:   "./app/scripts"
    styles:    "./app/styles"
    templates: "./app/templates"
  build:
    all:       "./build"
    assets:    "./build"
    scripts:   "./build/scripts"
    styles:    "./build/styles"
  bower:       "./bower_components"
  force:       "./src"

#
appName = "MyApp"

#
debug = (gutil.env.type != 'production')


###
# Tasks
###

# Copy all static files in src directory to temporary build directory
gulp.task "build:assets", ->
  gulp.src "#{paths.src.assets}/**", base: "#{paths.src.assets}"
    .pipe plumber()
    .pipe changed(paths.build.assets)
    .pipe gulp.dest "#{paths.build.assets}"

# Building CSS files from LESS source
gulp.task "build:styles", ->
  gulp.src "#{paths.src.styles}/main.less"
    .pipe plumber()
    .pipe less()
    .pipe gulp.dest paths.build.styles
    .pipe minify()
    .pipe rename(extname: ".min.css")
    .pipe gulp.dest paths.build.styles

# Compile CoffeeScripts in src directory
gulp.task "build:coffee", ->
  gulp.src "#{paths.src.scripts}/**/*.coffee"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".js")
    .pipe coffee bare: true
    .pipe gulp.dest paths.build.scripts

# Compile CoffeeScript JSX in src directory
gulp.task "build:cjsx", ->
  gulp.src "#{paths.src.scripts}/**/*.cjsx"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".js")
    .pipe cjsx bare: true
    .pipe gulp.dest paths.build.scripts

# Compile ES6 JavaScripts (also supports React JSX) in src directory
gulp.task "build:babel", ->
  gulp.src "#{paths.src.scripts}/**/*.{js,jsx}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".js")
    .pipe babel()
    .pipe rename(extname: ".js")
    .pipe gulp.dest paths.build.scripts

# All Script Compilation Task
gulp.task "build:scripts", [ "build:coffee", "build:cjsx", "build:babel" ]

# Compile React Template file
gulp.task "build:templates", ->
  gulp.src "#{paths.src.templates}/**/*.rt", base: "#{paths.src.templates}"
    .pipe plumber()
    .pipe changed(paths.build.scripts, extension: ".rt.js")
    .pipe rt(modules: "commonjs")
    .pipe gulp.dest paths.build.scripts

# Bundle files into one runnable script file using browserify
gulp.task "build:bundle", ->
  browserify "#{paths.build.scripts}/main.js"
    .bundle()
    .pipe source("main-bundle.js")
    .pipe gulp.dest paths.build.scripts
    .pipe streamify uglify()
    .pipe rename(extname: ".min.js")
    .pipe gulp.dest paths.build.scripts

# All build tasks
gulp.task "build", [ "build:assets", "build:styles", "build:scripts", "build:templates",  "build:bundle" ]

# Cleanup built files
gulp.task "clean", ->
  del [ paths.build.all ]

# Zip all built files as a static resource file
gulp.task "archive:app", ->
  gulp.src "#{paths.build.all}/**"
    .pipe plumber()
    .pipe zip("#{appName}.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"

# Zip bower installed libralies
gulp.task "archive:lib", ->
  gulp.src "#{paths.bower}/**"
    .pipe plumber()
    .pipe zip("#{appName}Lib.resource")
    .pipe gulp.dest "#{paths.force}/staticresources"

# Zip all static resources
gulp.task "archive", [ "archive:lib", "archive:app" ]

# Deploying package to Salesforce
gulp.task "deploy", [ "archive" ], ->
  gulp.src "./pkg/**/*", base: "."
    .pipe plumber()
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
  server.use express.static(paths.build.all)
  server.use express.static(paths.bower)
  server.listen port

#
gulp.task "watch:build", ->
  createOnChangeHandler = (label) ->
    (e) ->
      console.log("File #{e.path} was #{e.type}, running 'build:#{label}' task...")

  gulp.watch "#{paths.src.templates}/**", [ "build:templates" ]
    .on "change", createOnChangeHandler("templates")
  gulp.watch "#{paths.src.scripts}/**", [ "build:scripts" ]
    .on "change", createOnChangeHandler("scripts")
  gulp.watch "#{paths.src.styles}/**", [ "build:styles" ]
    .on "change", createOnChangeHandler("styles")
  gulp.watch "#{paths.src.assets}/**", [ "build:assets" ]
    .on "change", createOnChangeHandler("assets")
  gulp.watch [
      "#{paths.build.scripts}/**/*.js"
      "!#{paths.build.scripts}/*-bundle?(.min).js"
    ], [ "build:bundle" ]
    .on "change", createOnChangeHandler("bundle")



#
gulp.task "watch:deploy", ->
  gulp.watch "#{paths.force}/**", [ "deploy" ]

#
gulp.task "watch", [ "watch:build", "watch:deploy" ]

#
gulp.task "dev", [ "serve", "watch:build" ]
gulp.task "default", [ "build" ]
