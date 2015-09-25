//
//  Runtime.swift
//  Pods
//
//  Created by Cesar on 9/28/15.
//
//

import Foundation
import Socket_IO_Client_Swift
import Alamofire
import PromiseKit
import JWT

public class Runtime{
    
    /**
    Initialize the SDK and connect to EXP.
    @param host,uuid,secret.
    @return Promise<Bool>.
    */
    public func start(host: String, uuid: String, secret: String)  -> Promise<Bool> {
        tokenSDK = JWT.encode(["uuid": uuid], .HS256(secret))
        return Promise { fulfill, reject in
            hostUrl=host
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer " + tokenSDK];
            socketManager.start_socket().then { (result: Bool) -> Void  in
                if result{
                    fulfill(true)
                }
            }
        }
    }
    
    /**
    Initialize the SDK and connect to EXP.
    @param host,user,password,organization.
    @return Promise<Bool>.
    */
    
    public func start(host:String , user: String , password:String, organization:String) -> Promise<Bool> {
        
        return Promise { fulfill, reject in
            hostUrl=host
            login(user, password, organization).then {(token: Token) -> Void  in
                tokenSDK = token.token
                Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer " + tokenSDK];
                socketManager.start_socket().then { (result: Bool) -> Void  in
                    if result{
                        fulfill(true)
                    }
                }
            }
        }
    }
    
    /**
    Stop socket connection.
    @param host,user,password,organization.
    @return Promise<Bool>.
    */
    public func stop(){
        socketManager.disconnect()
        tokenSDK = ""
    }

    /**
    Connection Socket
    @param name for connection(offline,line),callback
    @return void
    */
    public func connection(name:String,callback:String->Void){
        socketManager.connection(name,  callback: { (resultListen) -> Void in
            callback(resultListen)
        })
    }

    
}