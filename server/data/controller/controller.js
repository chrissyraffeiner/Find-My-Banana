const express = require("express")
const app = express()


/*const MongoClient = require('mongodb').MongoClient
const url = "mongodb://localhost:27017/"
const dbName = "FindMyBananaDB"
const client = new MongoClient(url)
const db = client.db(dbName)*/
app.use(express.json());

const repo = require("../repository/repository")

app.get("/message", function(req,res) {
    res.send(repo.message())
})

app.get("poll", function(req,res) {
    res.send(repo.poll())
})

app.get("/getUsers/:token", function(req,res) {
    res.send(repo.getUser(req))
})

app.get("/checkToken/:token", function(req,res){
    let antwort = repo.checkToken(req, res)
   // res.send(antwort)
})

app.post("/createGame", function(req,res) {
    res.send(repo.createGame(req))
})

app.post("/joinGame", function(req,res){
    res.send(repo.joinGame(req))
})

app.listen(3000, function() {
    console.log("server listens on port 3000")
})