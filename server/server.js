const express = require("express");
const app = express();
const socket = require("socket.io");
const http = require("http").createServer(express);
const cryp = require('crypto');
var MongoClient = require('mongodb').MongoClient;
let url = "mongodb://localhost:27017/";
let dbName = "FindMyBananaDB";
const bodyParser = require("body-parser")
const semaphore = require("node-semaphore")

var clientliste = [];
var clientsResList = []
app.use(bodyParser.urlencoded({extended: false}))
app.use(bodyParser.json())
var timeout
let test = false
let index = 0

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

app.use(express.json());
app.post("/joinGame", function(req, res){
  MongoClient.connect(url, function(err, db) {
    if (err) throw err;
    var dbo = db.db(dbName);
    var query = {gamecode: req.body.token};
    console.log(query)
    dbo.collection("Game").find(query).toArray(function(err, result) {
      if (err) throw err;
      newlist = new Array();
      console.log(result);
      if(result[0].userlist != null){
        result[0].userlist.forEach(element => {
          newlist.push(element);
        });
      }
      user = {username: req.body.username, punkte: 0};
      //Long Polling
      //clients.push({username: req.body.username, gamecode: req.body.token});

      newlist.push(user);
      var newvalues = { $set: {userlist: newlist}};
      dbo.collection("Game").updateOne(query, newvalues, function(err, res) {
        if (err) throw err;
        console.log("User " +  req.body.username + " added");
      });
      db.close();
    });
  });
  //res.send("User " +  req.body.username + " joined");
  //send all users
  let token = req.body.token
  console.log("clientsResList length: " + clientsResList[token].length)

  console.log("push clientListe")
  clientliste[req.body.token].push(req.body.username);
  sem.release()
  clearTimeout(this.timeout)
  console.log("vor while schleife")
  while(clientsResList[token].length > 0){
    console.log(typeof clientliste[token].length)
    let client = clientsResList[token].pop()
    let count = clientliste[token].length.toString()
    let data = {count: count, new: req.body.username}
    //client.send(data)
    client.send({count: count, users: clientliste[token]})
    //client.send("yes")
  }
  res.send("User " +  req.body.username + " joined");
});

app.get("/poll",function(req,res){
  console.log(semaphore)
    console.log("poll here")
    let counter = req.query.counter;
    let token = req.query.token;
    if(counter == 0 || clientsResList[token].length == 0 || test){
      clientsResList[token].push(res)
      if(clientsResList[token.length] == index){
        test = false
      }
    }
      sem.acquire(()=>{
        this.timeout=setTimeout(()=>{
          console.log("timeout")
          index = clientsResList[token].length
          while(clientsResList[token].length > 0){
            clientsResList[token].pop()
          }
          test = true
          sem.release()
          return res.send("Try again")
        },29000)//Timeout 15sek?
      })

     /* if(clientliste[token].length > counter){//neuer ist inzwischenzeit dazu gejoined
        console.log("something new")
        console.log(t)
        clearTimeout(t)
        console.log(t)
        //res.send(clientliste[token]);
        let count = clientliste[token].length.toString()
        let data = {count: count, new: clientliste[token][counter]}
        //res.send(data)
        sem.release()
        res.send(data)
      }else{*/
        console.log("counter: "+counter)
      //}
});

app.get("/deleteAll", (req,res)=>{
  MongoClient.connect(url, function(err, db) {
    var dbo = db.db(dbName);
    dbo.collection("Game").drop(function (err, delOk) {
      if (err) throw err;
      if (delOk) console.log("ok")
      db.close()
    })
  });
  res.send("deleted")
})

app.get("/findAll", (req, res)=>{
  MongoClient.connect(url, function(err, db) {
    if (err) throw err;
    var dbo = db.db(dbName);
    //var query = {gamecode: req.body.token};
    dbo.collection("Game").find().toArray(function(err, result) {
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
})
var sem
//Erstellt einen Gamecode, und weißt angegebene Zeit und anzahl der Emojis zu.
app.use(express.json());
app.post("/createGame", function(req, res){
    let token = Math.round(Math.random()*100000);

    //Long Polling Liste
    clientliste[token.toString()] = new Array();
    clientsResList[token.toString()] = new Array()
    
    sem = semaphore(5)

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
      console.log("game created")
    res.send(token.toString());
});

//Schaut ob das Spiel bereits erstellt wurde
app.use(express.json());
app.get("/checktoken/:token", function(req, res){
  let token = req.params.token
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        var dbo = db.db(dbName);
        var query = {gamecode: token};
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