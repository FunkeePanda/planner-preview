#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const timestamp = Date.now();
const htmlFile = path.join(__dirname, 'index.html');

// Read the HTML file
let html = fs.readFileSync(htmlFile, 'utf8');

// Update cache-busting comment
html = html.replace(/<!-- cache-bust: .* -->/, `<!-- cache-bust: ${new Date().toISOString()} -->`);

// For future external files, this would also update:
// - <link rel="stylesheet" href="styles.css"> to <link rel="stylesheet" href="styles.css?v=${timestamp}">
// - <script src="app.js"></script> to <script src="app.js?v=${timestamp}"></script>

// Replace any existing cache-busting parameters in external resources
html = html.replace(/(\.(css|js))\?v=\d+/g, `$1?v=${timestamp}`);

// Add cache-busting to any new external resources that don't have it
html = html.replace(/<link([^>]*href=["']([^"']*\.css)["'][^>]*)>/g, (match, attrs, href) => {
  if (href.includes('?v=')) return match;
  return match.replace(href, `${href}?v=${timestamp}`);
});

html = html.replace(/<script([^>]*src=["']([^"']*\.js)["'][^>]*)>/g, (match, attrs, src) => {
  if (src.includes('?v=')) return match;
  return match.replace(src, `${src}?v=${timestamp}`);
});

// Write the updated HTML
fs.writeFileSync(htmlFile, html);

console.log(`Cache-busting updated with timestamp: ${timestamp}`);