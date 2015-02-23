"use strict";

var React = require("react");

module.exports = React.createClass({
  render: function() {
    return <div className={this.props.className}>Bar: {this.props.children}</div>
  }
})
