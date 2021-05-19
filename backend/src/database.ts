import mongoose from 'mongoose'
import { isJSDocAugmentsTag } from 'typescript'


export async function startConnection(){
//127.0.0.1
//mongo
    const db = await mongoose.connect('mongodb://unihub_mongo_1:27017/UniHub',{ 
        useNewUrlParser: true,
        useFindAndModify: false
    })

    console.log('Connection to Database stablished')
}
mongoose.set('debug', true);
 