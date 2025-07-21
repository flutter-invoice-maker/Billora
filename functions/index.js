const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Example HTTP function
testFunction = functions.https.onRequest((req, res) => {
  res.send('Hello from Billora Cloud Functions!');
});

exports.testFunction = testFunction; 