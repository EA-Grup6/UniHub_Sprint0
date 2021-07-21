"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFollowers = exports.getUserImage = exports.updateFollowers = exports.getSubjects = exports.getDegrees = exports.getUniversities = exports.getUser = exports.getAdmin = exports.getUsers = exports.updateUser = exports.deleteAll = exports.checkToken = exports.deleteUser = exports.loginUser = exports.createUser = void 0;
const User_1 = __importDefault(require("../models/User"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const University_1 = __importDefault(require("../models/University"));
const Faculty_1 = __importDefault(require("../models/Faculty"));
const Degree_1 = __importDefault(require("../models/Degree"));
const feedPublication_1 = __importDefault(require("../models/feedPublication"));
const offer_1 = __importDefault(require("../models/offer"));
let mongoose = require('mongoose');
async function createUser(req, res) {
    let { username, password } = req.body;
    let newUser = new User_1.default();
    newUser._id = new mongoose.Types.ObjectId();
    newUser.username = username;
    newUser.password = password;
    newUser.fullname = '';
    newUser.description = '';
    newUser.university = '';
    newUser.degree = '';
    newUser.role = '';
    newUser.subjectsDone = [];
    newUser.subjectsRequested = [];
    newUser.recommendations = '';
    newUser.isAdmin = false;
    newUser.phone = '';
    newUser.following = [];
    newUser.followers = [];
    newUser.profilePhoto = 'https://d500.epimg.net/cincodias/imagenes/2016/07/04/lifestyle/1467646262_522853_1467646344_noticia_normal.jpg';
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
async function checkToken(req, res) {
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                return res.status(200).send({ message: 'Authorized' });
            }
        });
    }
    else {
        return res.status(205).send({ message: 'Authorization error' });
    }
}
exports.checkToken = checkToken;
///////////
async function deleteAll(req, res) {
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
                    await feedPublication_1.default.remove({ username: req.params.username });
                    await feedPublication_1.default.find({ feedPublication: req.params.username });
                    await offer_1.default.find({ offer: req.params.username });
                    return res.status(200).send({ message: "Data erased correctly" });
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
exports.deleteAll = deleteAll;
async function updateUser(req, res) {
    let { username, password, fullname, description, university, degree, role, subjectsDone, subjectsRequested, phone, profilePhoto } = req.body;
    const Btoken = req.headers['authorization'];
    const updateData = {
        fullname: fullname,
        description: description,
        university: university,
        degree: degree,
        role: role,
        subjectsDone: subjectsDone,
        subjectsRequested: subjectsRequested,
        phone: phone,
        profilePhoto: profilePhoto
    };
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
async function getUniversities(req, res) {
    let listUniversities = await University_1.default.find();
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    if (listUniversities.length != 0) {
                        return res.status(200).header('Content Type - application/json').send(listUniversities);
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
exports.getUniversities = getUniversities;
async function getDegrees(req, res) {
    let schoolParam = req.params.school;
    let school = await Faculty_1.default.findOne({ name: schoolParam });
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    if (school != null) {
                        return res.status(200).header('Content Type - application/json').send(school);
                    }
                    else {
                        return res.status(201).send({ message: "School not found" });
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
exports.getDegrees = getDegrees;
async function getSubjects(req, res) {
    let degreeParam = req.params.degree;
    let degree = await Degree_1.default.findOne({ name: degreeParam });
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    if (degree != null) {
                        return res.status(200).header('Content Type - application/json').send(degree);
                    }
                    else {
                        return res.status(201).send({ message: "Degree not found" });
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
exports.getSubjects = getSubjects;
async function updateFollowers(req, res) {
    let { follower, followed } = req.body;
    const Btoken = req.headers['authorization'];
    const action = req.params.action;
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    const userfollowing = await User_1.default.findOne({ username: follower });
                    const userfollowed = await User_1.default.findOne({ username: followed });
                    let following = userfollowing === null || userfollowing === void 0 ? void 0 : userfollowing.following;
                    let followers = userfollowed === null || userfollowed === void 0 ? void 0 : userfollowed.followers;
                    if (action == 'follow') {
                        followers === null || followers === void 0 ? void 0 : followers.push(follower);
                        following === null || following === void 0 ? void 0 : following.push(followed);
                        await User_1.default.findOneAndUpdate({ username: follower }, { following: following });
                        await User_1.default.findOneAndUpdate({ username: followed }, { followers: followers });
                        return res.status(200).send({ message: 'Followers correctly updated' });
                    }
                    else if (action == 'unfollow') {
                        const followerIndex = findUsername(follower, followers);
                        const followingIndex = findUsername(followed, following);
                        if (followerIndex != null && followingIndex != null) {
                            followers === null || followers === void 0 ? void 0 : followers.splice(followerIndex, 1);
                            following === null || following === void 0 ? void 0 : following.splice(followingIndex, 1);
                            await User_1.default.findOneAndUpdate({ username: follower }, { following: following });
                            await User_1.default.findOneAndUpdate({ username: followed }, { followers: followers });
                            return res.status(200).send({ message: 'Followers correctly updated' });
                        }
                    }
                }
                catch {
                    return res.status(201).send({ message: "Followers couldn't be updated" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.updateFollowers = updateFollowers;
async function getUserImage(req, res) {
    let username = req.params.username;
    const Btoken = req.headers['authorization'];
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    let user = await User_1.default.findOne({ username: username });
                    let userImage = user === null || user === void 0 ? void 0 : user.profilePhoto;
                    return res.status(200).send(userImage);
                }
                catch {
                    return res.status(201).send({ message: "Database error while trying to find profile photo" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.getUserImage = getUserImage;
function findUsername(username, list) {
    for (var count = 0; count < (list === null || list === void 0 ? void 0 : list.length); count++) {
        if (list[count] == username) {
            return count;
        }
    }
}
async function getFollowers(req, res) {
    const Btoken = req.headers['authorization'];
    let { usernameSearching, usernameSearched } = req.body;
    if (typeof Btoken !== undefined) {
        req.token = Btoken;
        jsonwebtoken_1.default.verify(req.token, 'mykey', async (error, authData) => {
            if (error) {
                return res.status(205).send({ message: 'Authorization error' });
            }
            else {
                try {
                    const usersearching = await User_1.default.findOne({ username: usernameSearching });
                    let following = usersearching === null || usersearching === void 0 ? void 0 : usersearching.following;
                    let followers = usersearching === null || usersearching === void 0 ? void 0 : usersearching.followers;
                    if (following != null && followers != null) {
                        if (following.find(usernameSearched) != null && followers.find(usernameSearched) != null) {
                            return res.status(200).send(usernameSearched);
                        }
                        else
                            return res.status(404).send({ message: 'User not found' });
                    }
                }
                catch {
                    return res.status(201).send({ message: "User couldn't be found on the database" });
                }
            }
        });
    }
    else {
        return res.status(204).send({ message: 'Unauthorized' });
    }
}
exports.getFollowers = getFollowers;
