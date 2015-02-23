"use strict";

React = require "react"
RootTmpl = require "./root.rt"

module.exports = React.createClass
  render: ->
    RootTmpl.apply(@)
