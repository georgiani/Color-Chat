
// user:
// {userName: "", password: ""}
const users = {}; // map of users 

// room:
// {
//  roomName: "",
//  description: "",
//  maxPeople: int,
//  private: bool,
//  creator: "",
//  users: [
//      username: {userName: ""}
//  ]
// }
const rooms = {}; 

// socket(server)
const io = require("socket.io") (
    require("http").createServer(
        function() {}
    ).listen(80)
);

io.on(
    "connection",
    io => {
        console.log("\nConnection established with a client");
        io.on(
            "validate",
            (dataIn, callback) => {
                if (users[dataIn.userName]) { // if the user exists
                    // then validate the password
                    if (user.password == dataIn.password) { 
                        callback({status: "ok"});
                    } else {
                        callback({status: "fail"});
                    }
                } else {
                    // if the user doesn't exists
                    // then map his username to his account
                    users[dataIn.userName] = dataIn; 
                    io.broadcast.emit("newUser", users);
                    callback({status: "created"});
                }
            }
        );

        // dataIn -> room, creator
        io.on(
            "create",
            (dataIn, callback) => {
                if (rooms[dataIn.roomName]) { // if the room exists
                    callback({status: "exists"}); // send a msg that tells so
                } else {
                    dataIn.users = {};
                    rooms[dataIn.roomName] = dataIn;
                    io.broadcast.emit("created", rooms);
                    callback({status: "created", rooms: rooms}); // the client
                    // that created the room will not receive the broadcast
                    // so send him an updated list of rooms too
                }
            }
        );

        io.on(
            "listRooms",
            (dataIn, callback) => {
                callback(rooms);
            }
        );

        io.on(
            "listUsers",
            (dataIn, callback) => {
                callback(users);
            }
        );

        // dataIn -> user, room
        io.on(
            "join",
            (dataIn, callback) => {
                const room = rooms[dataIn.roomName]; // get the room 

                // if the number of users in the room is >= maxpeople of the room
                // then the status is "full"
                if (Object.keys(room.users).length >= room.maxPeople) {
                    callback({status: "full"});
                } else {
                    // put the user from the global list of users
                    // in the list of users from the room
                    room.users[dataIn.userName] = users[dataIn.userName];
                    io.broadcast.emit("joined", room); // send the room descriptor
                    // to everyone so they know someone joined
                    callback({status: "joined", room: room}); // send the room descriptor
                    // back to the client so
                }
            }
        );
        
        // dataIn -> user, message, room
        io.on(
            "post",
            (dataIn, callback) => {
                io.broadcast.emit("posted", dataIn);
                callback({status: "ok"});
            }
        );

        // dataIn -> inviter, invited, room
        io.on(
            "invite",
            (dataIn, callback) => {
                io.broadcast.emit("invited", dataIn);
                callback({status: "ok"});
            }
        );

        // dataIn -> user, room
        io.on(
            "leave",
            (dataIn, callback) => {
                const room = rooms[dataIn.roomName];
                delete room.users[dataIn.userName];
                io.broadcast.emit("left", room);
                callback({status: "ok"});
            }
        );

        // Actions that can be done only by the admin
        io.on(
            "close",
            (dataIn, callback) => {
                delete rooms[dataIn.roomName];
                io.broadcast.emit("closed", {roomName: dataIn.roomName, rooms: rooms});
                callback(rooms);
            }
        );

        io.on(
            "kick",
            (dataIn, callback) => {
                delete rooms[dataIn.roomName].users[dataIn.userName];
                io.broadcast.emit("kicked", rooms[dataIn.roomName]);
                callback({status: "ok"});
            }            
        );
    }
);