const express = require("express")
const app = express()


/*const MongoClient = require('mongodb').MongoClient
const url = "mongodb://localhost:27017/"
const dbName = "FindMyBananaDB"
const client = new MongoClient(url)
const db = client.db(dbName)*/

const repo = require("../repository/repository")

app.get("/message", function(req,res) {
    res.send(repo.message())
})

app.get("poll", function(req,res) {

})

app.get("/findAll", function(req,res) {

})

app.get("/checktocken/:token", function(req,res){

})

app.post("/createGame", function(req,res) {

})

app.post("/joinGame", function(req,res){

})

app.listen(3000, function() {
    console.log("server listens on port 3000")
})