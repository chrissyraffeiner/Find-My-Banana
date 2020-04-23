const express = require("express")
const app = express();
const socket = require("socket.io")
const http = require("http").createServer(express)
const cryp = require('crypto')

app.get("/", function(req, res){
    res.send('<h1>Hello world</h1>');
})

app.get("/message", function(req,res){
    res.send("server works")
})

app.get("/joinGame", function(req, res){
    console.log("sth")
    res.send("joined")
})



/**
 * Erstellt einen Gamecode, und weißt angegebene Zeit und anzahl der Emojis zu.
 * 
 * 
 */

app.use(express.json())
app.post("/createGame", function(req, res){
    console.log("here")
    let anzahl = req.body.anz
    let timeInSec = req.body.timeInSec
    let token;
        token = Math.round(Math.random()*1000000);


    res.send("" + token);
})


app.listen(3000, function(){
    console.log("server listens on port 3000")
})
