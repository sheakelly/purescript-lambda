const { handler } = require("./output/S3EventSource");

// handler({ id: 1, message: "Yo Dawg" }).then((r) => console.log(r));

handler({ id2: 1, text: "Yo" }).then((r) => console.log(r));

handler({
  Records: [{ s3: { name: "bucket name", arn: "arn value" } }],
}).then((r) => console.log(r));
