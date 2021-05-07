"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUser = exports.getAdmin = exports.getUsers = exports.updateUser = exports.deleteUser = exports.loginUser = exports.createUser = exports.helloWorld = void 0;
const User_1 = __importDefault(require("../models/User"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
function helloWorld(req, res) {
    return res.send('Hello World !!!');
}
exports.helloWorld = helloWorld;
async function createUser(req, res) {
    const Btoken = req.headers['authorization'];
    let { username, password, isAdmin } = req.body;
    let newUser = new User_1.default();
    newUser.username = username;
    newUser.password = password;
    newUser.fullname = '';
    newUser.description = '';
    newUser.university = '';
    newUser.degree = '';
    newUser.role = '';
    newUser.subjectsDone = '';
    newUser.subjectsRequested = '';
    newUser.recommendations = '';
    newUser.isAdmin = false;
    newUser.phone = '';
    var registeredUser = await User_1.default.findOne({ username: newUser.username });
    try {
        if (registeredUser != null) {
            return res.status(201).send({ message: "User already exists" });
        }
        else {
            let result = await newUser.save();
            return res.status(200).send(result);
        }
    }
    catch {
        return res.status(500).send({ message: "Internal server error" });
    }
}
exports.createUser = createUser;
async function loginUser(req, res) {
    let { username, password, tag } = req.body;
    const user = { username: username, password: password, tag: tag };
    console.log("Username: " + user.username);
    console.log("Password: " + user.password);
    const registeringUser = new User_1.default(user);
    var registeredUser = await User_1.default.findOne({ username: registeringUser.username });
    try {
        if (registeredUser != null) {
            if (registeredUser.get('password') == registeringUser.password) {
                let registeredUserId = registeredUser._id;
                var token = await jsonwebtoken_1.default.sign({ id: registeredUserId }, 'mykey', { expiresIn: 86400 });
                if (registeredUser.get('isAdmin')) {
                    return res.status(202).send(token);
                }
                else
                    return res.status(200).send(token);
            }
            else {
                return res.status(201).send('Wrong password');
            }
        }
        else {
            return res.status(404).send('User not found');
        }
    }
    catch {
        return res.status(500).send('Internal server error');
    }
}
exports.loginUser = loginUser;
async function deleteUser(req, res) {
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    await User_1.default.findOneAndRemove({ username: req.params.username });
                    return res.status(200).send({ message: "User correctly deleted" });
                }
                catch {
                    return res.status(500).send({ message: "Internal server error" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.deleteUser = deleteUser;
async function updateUser(req, res) {
    let { username, password, fullname, description, university, degree, role, subjectsDone, subjectsRequested, phone } = req.body;
    const Btoken = req.headers['authorization'];
    const updateData = {
        password: password,
        fullname: fullname,
        description: description,
        university: university,
        degree: degree,
        role: role,
        subjectsDone: subjectsDone,
        subjectsRequested: subjectsRequested,
        phone: phone
    };
    console.log(updateData);
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    await User_1.default.findOneAndUpdate({ username: username }, updateData);
                    return res.status(200).send({ message: 'User correctly updated' });
                }
                catch {
                    return res.status(201).send({ message: "User couldn't be updated" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.updateUser = updateUser;
async function getUsers(req, res) {
    const Btoken = req.headers['authorization'];
    const users = await User_1.default.find();
    console.log(users);
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    if (users != null) {
                        return res.status(200).header('Content Type - application/json').send(users);
                    }
                    else {
                        return res.status(404).send({ message: "Users not found" });
                    }
                }
                catch {
                    return res.status(500).send({ message: "Internal server error" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.getUsers = getUsers;
async function getAdmin(req, res) {
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    let user = await User_1.default.findById(req.params.id);
                    if (user != null) {
                        if (user.isAdmin == true) {
                            return res.status(200).send({ message: "User is Admin" });
                        }
                        else {
                            return res.status(201).send({ message: "User is not Admin" });
                        }
                    }
                    else {
                        return res.status(202).send({ message: "User not found" });
                    }
                }
                catch {
                    return res.status(500).send({ message: "Internal server error" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.getAdmin = getAdmin;
async function getUser(req, res) {
    let username = req.params.username;
    let user = await User_1.default.findOne({ username: username });
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    if (user != null) {
                        return res.status(200).header('Content Type - application/json').send(user);
                    }
                    else {
                        return res.status(201).send({ message: "User not found" });
                    }
                }
                catch {
                    return res.status(500).send({ message: "Internal server error" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.getUser = getUser;
