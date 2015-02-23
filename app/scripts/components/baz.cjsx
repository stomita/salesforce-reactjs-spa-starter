"use strict"

React = require "react"

module.exports = React.createClass
  render: ->
    <div className={this.props.className}>Baz: {this.props.children}</div>
