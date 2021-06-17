import mongoose from 'mongoose'
import { isJSDocAugmentsTag } from 'typescript'


export async function startConnection(){
//127.0.0.1
//mongo
    const db = await mongoose.connect('mongodb://mongo:27017/UniHub',{ 
        useNewUrlParser: true,
        useFindAndModify: false,
        useUnifiedTopology: true
    })

    console.log('Connection to Database stablished')
}
mongoose.set('debug', true);