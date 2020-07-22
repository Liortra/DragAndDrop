import Foundation

class Board: Codable {
    
    var id:String
    var title: String
    var items: [String]
    var index: Int
    
    static var uidFactory = 0
    
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
        self.id =  UUID().uuidString
        self.index = Board.getUniqueIdentifier()
    }
    
    init(dict:[String:Any]) {
        self.title = dict["title"] as! String
        self.items = dict["items"] as! [String]
        self.id = dict["id"] as! String
        self.index = dict["index"] as! Int
       }
    
    func returnAsDictionary()->[String:Any]{
        var dict : [String:Any] = [:]
        
        dict["title"] = self.title
        dict["items"] = self.items
        dict["id"] = self.id
        dict["index"] = self.index
        return dict
    }
    
    static func getUniqueIdentifier() -> Int {
        uidFactory += 1
        return uidFactory
    }
}
