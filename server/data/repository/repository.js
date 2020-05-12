const MongoClient = require('mongodb').MongoClient
const url = "mongodb://localhost:27017/"
const dbName = "FindMyBananaDB"
//const client = new MongoClient(url)

//DB erstellen
MongoClient.connect(url + dbName, function (err, client) {
    if (err) console.log("error in DB erstellen: " + err)
    console.log(dbName + " created!")
    client.close()
})

//Collection Game erstellen (Tabelle)
MongoClient.connect(url, function (err, client) {
    if (err) console.log("error in connect beim Game anlegen: " + err)
    const db = client.db(dbName)
    db.createCollection("Game", function (err, res) {
        if (err) console.log("error bei Geme erstellen: " + err)
        console.log("Collection Game created!")
        client.close()
    })
})


module.exports = {
    message: function () {
        return "server works"
    },

    poll: function () {

    },

    getUser: async function (req) {
        MongoClient.connect(url, function (err, client) {
            if (err) console.log("error in join game: " + err)
            const db = client.db(dbName)
            let cursor = db.collection("Game").find({ _id: req.params.token.toString() })
            cursor.forEach(c => {
                console.log(c)
                return c.userlist
            })
            client.close()
        })
    },

    checkToken: function (req, res) {
        let exist = "hi"
        MongoClient.connect(url, function (err, client) {
            if (err) console.log("error in check token: " + err)
            const db = client.db(dbName)
            console.log(req.params.token)
            let cursor = db.collection("Game").find(
                { _id: req.params.token.toString() }
            )
            cursor.forEach(c => {
                console.log(true)
                exist = "ja"
                console.log(exist)
                // return exist
            })
            // res.send(exist)
            return exist
            client.close()
        })
        //   return exist
    },

    createGame: function (req) {
        let token
        do {
            token = Math.floor(Math.random() * 100000)
        } while (token < 10000 || token >= 100000)
        MongoClient.connect(url, function (err, client) {
            if (err) console.log("error in create game: " + err)
            const db = client.db(dbName)
            db.collection("Game").insertOne(
                { _id: token.toString(), anzahl: req.body.anz, timeInSec: req.body.timeInSec, userlist: [] },
                function (err, result) {
                    console.log("createGame" + result)
                    if (err) console.log("error in create game: " + err)
                }
            )
            client.close()
        })
        return token.toString()
    },

    joinGame: function (req) {
        MongoClient.connect(url, function (err, client) {
            if (err) console.log("error in join game: " + err)
            const db = client.db(dbName)
            let cursor = db.collection("Game").updateOne(
                { _id: req.body.token.toString() },
                { $push: { userlist: req.body.username } }
            )
            client.close()
            return cursor.userlist
        })
    }
}