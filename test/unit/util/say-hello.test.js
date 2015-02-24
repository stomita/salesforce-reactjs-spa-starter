var assert = require("power-assert");
var sayHello = require("../../../app/scripts/util/say-hello");

describe("say hello", function() {
  it("should match message", function() {
    var msg = sayHello("John");
    assert(msg === "Hello, John");
  });
});