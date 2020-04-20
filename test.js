const { handler } = require("./output/Event");

handler({ id: 1, text: "Yo" }).then((r) => console.log(r));
