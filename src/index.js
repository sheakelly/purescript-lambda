const Basic = require("../output/Basic");
const Event = require("../output/Event");

module.exports.basic = Basic.handler;
module.exports.event = (event) => Event.handler(event)();
