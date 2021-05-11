import {Schema,model,Document} from 'mongoose';

const schema = new Schema({
    username: String,
    password: String,
    fullname: String,
    description: String,
    university: String,
    degree: String,
    role: String,
    subjectsDone: Array,
    subjectsRequested: Array,
    recommendations: String,
    phone: String,
    isAdmin: Boolean,
    followers: Array,
    following: Array
    //Coins: Number
}, {collection: 'users'});

interface IUser extends Document {
    username: string;
    password: string;
    fullname: string;
    description: string,
    university: string,
    degree: string,
    role: string,
    subjectsDone: Array<string>,
    subjectsRequested: Array<string>,
    recommendations: string,
    isAdmin: Boolean;
    phone: string,
    followers: Array<string>;
    following: Array<string>;
    //Coins: Number
}

export default model<IUser>('User',schema);