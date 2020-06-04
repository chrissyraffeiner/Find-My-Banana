const express = require("express")
const app = express()
const MongoClient = require('mongodb').MongoClient
let url = "mongodb://localhost:27017/"
let dbName = "findMyBananaDB"
const bodyParser = require("body-parser")
const semaphore = require("node-semaphore")
const fs = require("fs")

var clientliste = [];
var clientsResList = []
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
let timeout
let timeouts = []
let test = false
let index = 0
let emojis
let foundItem = []

let users = []

//DB erstellen
MongoClient.connect(url + dbName, function (err, db) {
  if (err) throw err;
  console.log("FindMyBananaDB created!");
  db.close();
});

//Collection Game erstellen (Tabelle)
MongoClient.connect(url, function (err, db) {
  if (err) throw err;
  var dbo = db.db(dbName);
  dbo.createCollection("Game", function (err, res) {
    if (err) throw err;
    console.log("Collection Game created!");
    db.close();
  });
});

//Message / Test
app.get("/message", function (req, res) {
  res.send("server works");
});


app.use(express.json());
app.post("/joinGame", function (req, res) {
  MongoClient.connect(url, function (err, db) {
    if (err) throw err;
    var dbo = db.db(dbName);
    var query = { gamecode: req.body.token };
    console.log(query)
    dbo.collection("Game").find(query).toArray(function (err, result) {
      if (err) throw err;
      newlist = new Array();
      console.log("result: " + result[0].userlist[0]);
      if (result[0].userlist != null) {
        result[0].userlist.forEach(element => {
          newlist.push(element);
        });
      }

      user = {username: req.body.username, emoji: req.body.emoji, punkte: 0};
      //Long Polling
      //clients.push({username: req.body.username, gamecode: req.body.token});
      newlist.push(user);
      var newvalues = { $set: { userlist: newlist } };
      dbo.collection("Game").updateOne(query, newvalues, function (err, res) {
        if (err) throw err;
        console.log("User " + req.body.username + " added");
      });
      db.close();
    });
  });
  //res.send("User " +  req.body.username + " joined");
  //send all users

  let token = req.body.token
  console.log("clientsResList length: " + clientsResList[token].length)
  console.log("push clientListe")
  clientliste[req.body.token].push({username:req.body.username, emoji:req.body.emoji, punkte: 0});
  sem.release()
  console.log("clear timeout join game")
  //clear all timeouts
  console.log(timeouts[token])
  for(let i = 0; i < timeouts[token].length; i++){
    clearTimeout(timeouts[token][i])
  }
  //clearTimeout(this.timeout)
  console.log("vor while schleife")
  console.log(clientliste[token])
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

app.get("/startGame", function(req,res){
  console.log("start game...")
  let token = req.query.token
  users[token] = new Array()
  foundItem[token] = new Array()
  sem.release()
  console.log("clear timeout")
  // clear all timeouts
  console.log("timeouts: ",timeouts[token].length)
  for(let i = 0; i < timeouts[token].length; i++){
    clearTimeout(timeouts[token][i])
  }
  //clearTimeout(this.timeout)
  while(clientsResList[token].length > 0){
    let client = clientsResList[token].pop()
    client.send("Game started")
  }
  counter = 0
  res.send("Game started")
})

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
        timeouts[token].push(setTimeout(()=>{
          console.log("timeout")
          index = clientsResList[token].length
          while(clientsResList[token].length > 0){
            clientsResList[token].pop()
          }
          test = true
          sem.release()
          return res.send("Try again")
        },29000))
      })
    
});

app.get("/emojiToFind", (req, res)=>{
  let rand = Math.floor(Math.random(10)*10)
  let keys = Object.keys(emojis)
  let values = Object.values(emojis)

  //let unicode = "\\u{" + keys[rand] + "}"

  let findItem = {"emoji": keys[rand],"name":values[rand]}
  console.log(findItem)

  res.send(findItem)
})

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
    dbo.collection("Game").find().toArray(function (err, result) {
      if (err) throw err;
      console.log(result);
      db.close();
      if (result.length == 0) {
        res.send(false);
      } else {
        res.send(true);
      }
    });
  });
})
var sem
//Erstellt einen Gamecode, und weißt angegebene Zeit und anzahl der Emojis zu.
app.use(express.json());
app.post("/createGame", function (req, res) {
  let token = Math.floor(Math.random() * 100000);

    //Long Polling Liste
    clientliste[token.toString()] = new Array();
    clientsResList[token.toString()] = new Array()
    timeouts[token.toString()] = new Array()

    console.log(timeouts[token.toString()])
    
    sem = semaphore(2)

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
app.get("/checktoken/:token", function (req, res) {
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

//äquivalent zu joinGame() 
app.use(express.json());
app.post("/foundItem", (req, res)=>{
  let token = req.body.token
  let username = req.body.username
  let emoji = req.body.emoji
  let punkte = req.body.punkte

  //upgrade punkte anzahl in db
  MongoClient.connect(url, function(err,db){
    if(err) throw err;
    var dbo = db.db(dbName)
    var query = {gamecode: token}

    dbo.collection("Game").find(query).toArray(function(err,result){
      if(err) throw err;
      console.log(result[0].userlist)
      result[0].userlist.forEach(user => {
        if(user["username"] == username){
          console.log("user found")
          emoji = user["emoji"]
          user["punkte"]++
          foundItem[token].push(user)
          sem.release()
          //clearTimeout(this.timeout)
          //clear all timeouts
          console.log("timeouts: ", timeouts[token])
          for(let i = 0; i < timeouts[token].length; i++){
            clearTimeout(timeouts[token][i])
          }
        }
      });
      var newlist = result[0].userlist
      var newvalues = {$set: {userlist: newlist}}
      dbo.collection("Game").updateOne(query, newvalues, (err,result)=>{
        if(err) throw err;
        console.log("updated")
        users[token] = newlist;
        while(clientsResList[token].length > 0){
          console.log(foundItem[token].length)
          let client = clientsResList[token].pop()
          let count = foundItem[token].length
          //let data = {count: count, new: req.body.username}
          //client.send(data)
          client.send({count: count, users: users[token]})
          //client.send("yes")
        }
        db.close()
      })
    })
  })

  //benachrichtigen von anderen spielern
  //res.send("User " +  req.body.username + " joined");
    //counter = foundItem[token].length
    //send data: counter und users --> [{username, emoji, punkte},...]
  res.send(users[token])
})

app.get("/findByToken/:token", (req,res)=>{
  let token = req.params.token
  MongoClient.connect(url, function(err,db){
    if(err) throw err;
    var dbo = db.db(dbName)
    var query = {gamecode: token}

    dbo.collection("Game").find(query).toArray(function(err,result){
      if(err) throw err;
      console.log(result[0].userlist)
      db.close()
    })
  })
  res.send("ok")
})

function readFile(){
  let rawdata = fs.readFileSync("emojis.json")
  emojis = JSON.parse(rawdata)
}

app.listen(3000, function () {
  readFile()
  console.log("server listens on port 3000");
});