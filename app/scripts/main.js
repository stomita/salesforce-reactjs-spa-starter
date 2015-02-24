"use strict";

var React = require("react");
var Root = require("./components/root");

var sayHello = require("./util/say-hello");

document.addEventListener("DOMContentLoaded", function() {
  React.render(React.createElement(Root, {}), document.body);
});
