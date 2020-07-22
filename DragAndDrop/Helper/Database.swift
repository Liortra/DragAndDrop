import Foundation
import Firebase

import FirebaseFirestore
import FirebaseFirestoreSwift

class Database {
     typealias CompletionSucces = (_ success : Bool?) -> Void
     typealias CompletionUserBoards = (_ boards : [Board]?) -> Void
    
    //MARK:- Create new user in the database
    static func createUser(firstName:String,lastName:String,email:String) -> String{
        var message: String = String()
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(email)
            .setData(["firstName":firstName,"lastName":lastName])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    message = "Error writing document: \(err)"
                } else {
                    print("Document successfully written!")
                    message = "Document successfully written!"
                }
            }
    return message
    }
    
    //MARK:- function for handle any change of single board
    static func setBoard(  board:Board ,  callBack :@escaping CompletionSucces){
        let dict = [board.id:board.returnAsDictionary()]
             if Auth.auth().currentUser != nil &&  Auth.auth().currentUser?.email != nil{
                 let db = Firestore.firestore()
                 db.collection("boards")
                     .document((Auth.auth().currentUser?.email)!)
                    .setData(dict,merge: true)
                     { (error) in
                         if error != nil{
                            callBack(false)
//                             print("error addNewData")
                         }
                         else{
                            callBack(true)
//                             print("good addNewData")
                         }
                 }
             }
         }
    
    //MARK:- get all boards of user from database
    static func getUserBoardsData(callBack :@escaping CompletionUserBoards){
        let db = Firestore.firestore()
        let email = (Auth.auth().currentUser?.email)!
        let docRef = db.collection("boards").document(email)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var arrBoards : [Board]  =  []
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                for (key, _) in document.data()! {
                    let boardObject = Board(dict: document[key] as! [String : Any])
                                    arrBoards.append(boardObject)
                }
                arrBoards.sort(by: { $0.index < $1.index})
                callBack(arrBoards)
            } else {
                print("Document does not exist")
                callBack(nil)
            }
        }
    }
}
