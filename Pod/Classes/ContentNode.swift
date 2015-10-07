//
//  Content.swift
//  Pods
//
//  Created by Cesar on 9/23/15.
//
//

import Foundation
import PromiseKit

public final class ContentNode: ResponseObject,ResponseCollection {
    public var document: [String:AnyObject] = [String:AnyObject]()
    public var children: [ContentNode] = []
    
    
    @objc required public init?(response: NSHTTPURLResponse, representation: AnyObject) {
         if let representation = representation as? [String: AnyObject] {
            for documentRep in representation{
                if("children" != documentRep.0){
                    document.updateValue(documentRep.1, forKey: documentRep.0)
                }
            }
        }
        if let childrenPath = representation.valueForKeyPath("children") as? [[String: AnyObject]] {
            self.children = ContentNode.collection(response:response, representation: childrenPath)
        }
    }
    
    @objc public static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [ContentNode] {
        var contents: [ContentNode] = []
            if let representation = representation as? [[String: AnyObject]] {
                for contentRepresentation in representation {
                    if let content = ContentNode(response: response, representation: contentRepresentation) {
                        contents.append(content)
                    }
                }
            }
        return contents
    }
    
    /**
    Get Children from Node
    @return Promise<[Content]>.
    */
    public func getChildren() ->Promise<[ContentNode]>{
        let childrenPromise = Promise<[ContentNode]> { fulfill, reject in
            if(!children.isEmpty){
                fulfill(children)
            }else{
                fulfill([])
            }
        }
        return childrenPromise
    }
    
    /**
    Get Url
    @return String.
    */
    public func getUrl () ->String{
        var urlPath = ""
        let subtype = self.document["subtype"] as! String;
        
        if("scala:content:url" == subtype){
            urlPath = self.document["url"] as! String
        }else if("scala:content:app" == subtype){
            let escapeUrl = self.document["path"]!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            urlPath = hostUrl + "/api/delivery" + escapeUrl + "/index.html"
        }else if("scala:content:file" == subtype){
            let escapeUrl = self.document["path"]!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            urlPath = hostUrl + "/api/delivery" + escapeUrl
        }
        
        return urlPath
    }
    
    /**
    Get Url to a file variant
    @return String.
    */
    public func getVariantUrl (name: String) ->String{
        var urlPath = ""
        let subtype = self.document["subtype"] as! String;
        if("scala:content:file" == subtype && hasVariant(name)){
            urlPath = getUrl() + "?variant=" + name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        
        return urlPath
    }
    
    public func hasVariant (name: String) ->Bool{
        if (self.document["variants"] != nil) {
            let variants = self.document["variants"] as! [String:AnyObject]
            return variants[name] != nil
        }
        
        return false;
    }
}
