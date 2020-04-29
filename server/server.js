const express = require("express");
const app = express();
const socket = require("socket.io");
const http = require("http").createServer(express);
const cryp = require('crypto');
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/";
var dbName = "FindMyBananaDB";

//DB erstellen
MongoClient.connect(url + dbName, function(err, db) {
  if (err) throw err;
  console.log("FindMyBananaDB created!");
  db.close();
});

//Collection Game erstellen (Tabelle)
MongoClient.connect(url, function(err, db) {
  if (err) throw err;
  var dbo = db.db(dbName);
  dbo.createCollection("Game", function(err, res) {
    if (err) throw err;
    console.log("Collection Game created!");
    db.close();
  });
}); 

//Message / Test
app.get("/message", function(req,res){
    res.send("server works");
});

//
app.use(express.json());
app.post("/joinGame", function(req, res){
  MongoClient.connect(url, function(err, db) {
    if (err) throw err;
    var dbo = db.db(dbName);
    var query = {gamecode: req.body.token};
    dbo.collection("Game").find(query).toArray(function(err, result) {
      if (err) throw err;
      newlist = new Array();
      if(result[0].userlist != null){
        result[0].userlist.forEach(element => {
          newlist.push(element);
        });
      }
      newlist.push({username: req.body.username, punkte: 0});
      var newvalues = { $set: {userlist: newlist}};
      dbo.collection("Game").updateOne(query, newvalues, function(err, res) {
        if (err) throw err;
        console.log("User " +  req.body.username + " added");
      });
      db.close();
    });
  });
    res.send("User " +  req.body.username + " joined");
});

//Erstellt einen Gamecode, und weißt angegebene Zeit und anzahl der Emojis zu.
app.use(express.json());
app.post("/createGame", function(req, res){
    let token = Math.round(Math.random()*1000000);

    //Store to DB
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        var dbo = db.db(dbName);
        var newgame = {gamecode: token.toString(), anzahl: req.body.anz, timeInSec: req.body.timeInSec, userlist: []};
        dbo.collection("Game").insertOne(newgame, function(err, res) {
          if (err) throw err;
          console.log("Spiel mit GameCode: " + token + ", Emojianzahl: " + req.body.anz + ", TimeInSec: " + req.body.timeInSec + " Useranz: " + [].length + " erstellt");
          db.close();
        });
      });
    res.send(token.toString());
});

//Schaut ob das Spiel bereits erstellt wurde
app.use(express.json());
app.post("/checktoken", function(req, res){
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        var dbo = db.db(dbName);
        var query = {gamecode: req.body.token};
        dbo.collection("Game").find(query).toArray(function(err, result) {
          if (err) throw err;
          console.log(result);
          db.close();
          if(result.length == 0){
            res.send(false);
          }else{
            res.send(true);
          } 
        });
    });
});

app.listen(3000, function(){
    console.log("server listens on port 3000");
});