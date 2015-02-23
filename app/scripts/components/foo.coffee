"use strict"

React = require "react"
FooTmpl = require "./foo.rt"

module.exports = React.createClass
  render: ->
    FooTmpl.apply(@)
