const find = process.argv[2];
const Nightmare = require("nightmare");
const nightmare = Nightmare({ show: true,  waitTimeout: 60 * 60 * 1000 });
nightmare
  .goto("https://crackstation.net/")
  .evaluate((find) => {
    document.querySelector("textarea").innerText = find;
  }, find)
  .wait(".results")
  .evaluate(() => document.querySelector(".results").innerHTML)
  .end()
  .then(console.log)
