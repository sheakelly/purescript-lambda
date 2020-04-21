const { handler } = require("./output/SimpleJson");

handler({ id: 1, message: "Yo Dawg" }).then((r) => console.log(r));
handler({ id2: 1, text: "Yo" }).then((r) => console.log(r));
