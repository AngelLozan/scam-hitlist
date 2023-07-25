// const {join} = require('path');

// module.exports = {
//   // Changes the cache location for Puppeteer.
//   cacheDirectory: join(__dirname, '.cache', 'puppeteer'),
//   launchOptions: {
//     args: ['--no-sandbox', '--disable-setuid-sandbox'],
//   },
// };


const { join } = require('path');

module.exports = {
  // Set Env var in heroku to point to executable path
  executablePath: process.env.GOOGLE_CHROME_BIN || '/usr/bin/google-chrome',
  // Changes the cache location for Puppeteer.
  cacheDirectory: join(__dirname, '.cache', 'puppeteer'),
  headless: true,
launchOptions: {
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
},
};
