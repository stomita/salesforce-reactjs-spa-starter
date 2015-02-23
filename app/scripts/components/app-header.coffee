"use strict";

React = require "react"
AppHeaderTmpl = require "./app-header.rt"

module.exports = React.createClass
  render: ->
    AppHeaderTmpl.apply(@)
