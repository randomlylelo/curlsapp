#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const inputFile = './curlsapp/Resources/Data/exercises_raw.json';
const outputFile = './curlsapp/Resources/Data/exercises.json';

console.log('Processing exercises_raw.json to remove gifUrl...');

try {
  // Read the file as text to preserve formatting
  const fileContent = fs.readFileSync(inputFile, 'utf8');
  
  // Remove gifUrl lines while preserving all other formatting
  // This regex matches lines that contain "gifUrl" with any amount of whitespace
  // and removes the entire line including the trailing comma if present
  const processedContent = fileContent.replace(/^\s*"gifUrl":\s*"[^"]*",?\s*\n/gm, '');
  
  // Clean up any potential double commas that might result from removing gifUrl lines
  const cleanedContent = processedContent
    .replace(/,(\s*\n\s*,)/g, '$1')  // Remove duplicate commas
    .replace(/,(\s*\n\s*})/g, '$1'); // Remove trailing commas before closing braces
  
  // Write the processed content to the output file
  fs.writeFileSync(outputFile, cleanedContent);
  
  console.log(`✅ Successfully processed ${inputFile} -> ${outputFile}`);
  console.log('✅ gifUrl properties have been removed while preserving formatting');
  
} catch (error) {
  console.error('❌ Error processing file:', error.message);
  process.exit(1);
}