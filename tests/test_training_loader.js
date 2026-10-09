const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

const loader = fs.readFileSync(path.join(__dirname, '../frontend/training.html'), 'utf8').match(/<script>([\s\S]*?)<\/script>/)[1];
const html = fs.readFileSync(path.join(__dirname, '../frontend/ui/zh-chest/index.html'), 'utf8');
let written = '';
const context = {
  location: {pathname: '/training/example/', replace() {throw Error('unexpected redirect');}},
  window: {},
  document: {open() {}, write(value) {written = value;}, close() {}},
  fetch: async url => {
    if (url.endsWith('/api/bootstrap')) return {ok: true, json: async () => ({base: '/training/example', variant: 'zh-chest'})};
    if (url === '/ui/zh-chest/index.html') return {ok: true, text: async () => html};
    throw Error(`unexpected request: ${url}`);
  },
};
vm.runInNewContext(loader, context);
setImmediate(() => {
  assert.match(written, /src="\/training\/example\/app\.js\?v=speech-3"/);
  assert.doesNotMatch(written, /src="\/ui\/zh-chest\/app\.js/);
  console.log('training loader uses authenticated speech script');
});
