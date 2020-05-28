const express = require("express")
const app = express()
const MongoClient = require('mongodb').MongoClient
let url = "mongodb://localhost:27017/"
let dbName = "FindMyBananaDB"
const bodyParser = require("body-parser")
const semaphore = require("node-semaphore")
const fs = require("fs")

//var clientliste = []
var clientsResList = []
var sem
var timeout
let test = false
let index = 0
let emojis

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.use(express.json())


//DB erstellen
MongoClient.connect(url + dbName, function (err, db) {
  if (err) throw err
  console.log("FindMyBananaDB created!")
  db.close()
})

//Collection Game erstellen (Tabelle)
MongoClient.connect(url, function (err, client) {
  if (err) throw err
  var db = client.db(dbName)
  db.createCollection("Game", function (err, res) {
    if (err) throw err
    console.log("Collection Game created!")
    client.close()
  })
})

//Collection User erstellen (Tabelle)
MongoClient.connect(url, function (err, client) {
  if (err) throw err
  var db = client.db(dbName)
  db.createCollection("User", function (err, res) {
    if (err) throw err
    console.log("Collection User created!")
    client.close()
  })
})

//Message / Test
app.get("/message", function (req, res) {
  res.send("server works")
})

app.post("/joinGame", function (req, res) {
  MongoClient.connect(url, function (err, client) {
    if (err) console.log("error in join game: " + err)
    const db = client.db(dbName)
    db.collection("Game").updateOne(
      { _id: req.body.token.toString() },
      {
        $push: {
          userlist: {
            username: req.body.username,
            emoji: req.body.emoji,
            punkte: "0"
          }
        }
      }
    )
    let cursor = db.collection("Game").find({ _id: req.body.token.toString() })
    let userlist = []
    cursor.forEach(c => {
      console.log(c.userlist)
      userlist = c.userlist
      console.log("setted: " + userlist)
      res.send(userlist)

      console.log("userlist: " + cursor)
      sem.release()
      clearTimeout(this.timeout)
      console.log("vor while-schleife")
      let token = req.body.token
      while (clientsResList[token].length > 0) {
        console.log(typeof clientsResList[token].length)
        let user = clientsResList[token].pop()
        //let count = clientliste[token].length.toString()
        //let data = {count: clientliste[token].length.toString(), new: req.body.username}
        //client.send(data)
        console.log(userlist)
        user.send({ count: userlist.length.toString(), users: userlist })
        //client.send("yes")
      }
      console.log("User " + req.body.username + " joined")
      //  console.log("send: " + userlist)
    })
    client.close()

  })
})

app.get("/poll", function (req, res) {
  console.log(semaphore)
  console.log("poll here")
  let counter = req.query.counter;
  let token = req.query.token;

  if (counter == 0 || clientsResList[token].length == 0 || test) {
    clientsResList[token].push(res)
    if (clientsResList[token.length] == index) {
      test = false

    }
  }

  sem.acquire(() => {
    this.timeout = setTimeout(() => {
      console.log("timeout")
      index = clientsResList[token].length
      while (clientsResList[token].length > 0) {
        clientsResList[token].pop()
      }
      test = true
      sem.release()
      return res.send("Try again")
    }, 29000)//Timeout 15sek?
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
  console.log("counter: " + counter)
  //}

})

app.get("/emojiToFind", (req, res)=>{
  let rand = Math.floor(Math.random(10)*10)
  let keys = Object.keys(emojis)
  let values = Object.values(emojis)

  let findItem = {"emoji":keys[rand],"name":values[rand]}

  res.send(findItem)
})

app.get("/deleteAll", (req, res) => {
  MongoClient.connect(url, function (err, client) {
    var db = client.db(dbName);
    db.collection("Game").drop(function (err, delOk) {
      if (err) console.log("error in deleteAll: " + err)
      if (delOk) console.log("ok")
      client.close()
    })
  });
  res.send("deleted")
})

//Gibt die User mit dem jeweiligen token zurück
app.get("/getUsers/:token", (req, res) => {
  MongoClient.connect(url, function (err, client) {
    if (err) console.log("error in join game: " + err)
    const db = client.db(dbName)
    let cursor = db.collection("Game").find({ _id: req.params.token.toString() })
    cursor.forEach(c => {
      console.log(c)
      res.send(c.userlist)
    })
    client.close()
  })
})
//Erstellt einen Gamecode, und weißt angegebene Zeit und anzahl der Emojis zu.

app.post("/createGame", function (req, res) {
  let token
  do {
    token = Math.floor(Math.random() * 100000)
  } while (token < 10000 || token >= 100000)

  //Long Polling Liste
  //clientliste[token.toString()] = new Array();
  clientsResList[token.toString()] = new Array()

  sem = semaphore(5)

  //Store to DB
  MongoClient.connect(url, function (err, client) {
    if (err) console.log("error in create game: " + err)
    var db = client.db(dbName);
    db.collection("Game").insertOne(
      { _id: token.toString(), anzahl: req.body.anz, timeInSec: req.body.timeInSec, userlist: [] },
      function (err, res) {
        if (err) console.log("error in create game: " + err)
        console.log("Spiel mit GameCode: " + token + ", Emojianzahl: " + req.body.anz + ", TimeInSec: " + req.body.timeInSec + " Useranz: " + [].length + " erstellt");
      });
    client.close()
  });
  console.log("game created")
  res.send(token.toString());

});

//Schaut ob das Spiel bereits erstellt wurde

app.get("/checktoken/:token", function (req, res) {
  MongoClient.connect(url, function (err, client) {
    if (err) throw err;
    const db = client.db(dbName);
    db.collection("Game").find({ _id: req.params.token }).toArray(function (err, result) {
      if (err) throw err;
      console.log(result);
      client.close();
      if (result.length == 0) {
        res.send(false);
      } else {
        res.send(true);
      }
    });

  });
});

function readFile(){
  let rawdata = fs.readFileSync("emojis.json")
  emojis = JSON.parse(rawdata)
}

app.listen(3000, function () {
  readFile()
  console.log("server listens on port 3000");
});