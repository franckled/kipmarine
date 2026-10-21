const fs = require('node:fs');
const path = require('node:path');
const { render } = require('@resvg/resvg-js');

const svgPath = path.join(__dirname, '..', 'assets', 'images', 'kipmarine_app_icon.svg');
const pngPath = path.join(__dirname, '..', 'assets', 'images', 'kipmarine_app_icon.png');
const svg = fs.readFileSync(svgPath, 'utf8');
const png = render(svg, { fitTo: { mode: 'width', value: 1024 } }).asPng();
fs.writeFileSync(pngPath, png);
console.log('KipMarine icon rendered to assets/images/kipmarine_app_icon.png');
