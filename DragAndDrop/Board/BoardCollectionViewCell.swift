import UIKit
import MobileCoreServices
import Firebase

class BoardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    weak var parentVC: BoardCollectionViewController?
    var board: Board?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.tableFooterView = UIView()
    }
    
    func setup(with data: Board) {
        self.board = data
        tableView.reloadData()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {
                return
            }
            
            guard let data = self.board else {
                return
            }
            data.items.append(text)
            Database.setBoard(board: data) { (success) in
                  DispatchQueue.main.async {
                if success! {
                            self.tableView.reloadData()
                }
                else {
                    data.items.removeLast()
                }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parentVC?.present(alertController, animated: true, completion: nil)
    }
}

//MARK:- Extension
extension BoardCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return board?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(board!.items[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK:- Extension
extension BoardCollectionViewCell: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        self.parentVC?.pickedUpIndex = indexPath.row
        self.parentVC?.pickedUpBoard = self.board
        guard let board = board, let stringData = board.items[indexPath.row].data(using: .utf8) else {
            return []
        }
        
        let itemProvider = NSItemProvider(item: stringData as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = (board, indexPath, tableView)
        
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        
        
        self.parentVC?.setupRemoveBarButtonItem()
        self.parentVC?.navigationItem.rightBarButtonItem = nil
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        self.parentVC?.setupAddButtonItem()
        self.parentVC?.navigationItem.leftBarButtonItem = nil
    }
    
}

//MARK:- Extension
extension BoardCollectionViewCell: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if coordinator.session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
                guard let string = items.first as? String else {
                    return
                }
                
                switch (coordinator.items.first?.sourceIndexPath, coordinator.destinationIndexPath) {
                case (.some(let sourceIndexPath), .some(let destinationIndexPath)):
                    // Same Table View
                    let updatedIndexPaths: [IndexPath]
                    if sourceIndexPath.row < destinationIndexPath.row {
                        updatedIndexPaths =  (sourceIndexPath.row...destinationIndexPath.row).map { IndexPath(row: $0, section: 0) }
                    } else if sourceIndexPath.row > destinationIndexPath.row {
                        updatedIndexPaths =  (destinationIndexPath.row...sourceIndexPath.row).map { IndexPath(row: $0, section: 0) }
                    } else {
                        updatedIndexPaths = []
                    }
                    self.tableView.beginUpdates()
                    self.board?.items.remove(at: sourceIndexPath.row)
                    self.board?.items.insert(string, at: destinationIndexPath.row)
                    self.tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
                    self.tableView.endUpdates()
                    break
                    
                case (nil, .some(let destinationIndexPath)):
                    // Move data from a table to another table
                    let text = self.parentVC?.pickedUpBoard?.items[self.parentVC!.pickedUpIndex!]
                    self.board?.items.insert(text!, at: destinationIndexPath.row)
                    
                    Database.setBoard(board: self.board!) { (success) in
                        if success!{
                            // now remove data from source data base
                            self.parentVC?.pickedUpBoard?.items.remove(at: self.parentVC!.pickedUpIndex!)
                            Database.setBoard(board: (self.parentVC?.pickedUpBoard!)!) { (success) in
                                if success! {
                                    self.parentVC!.reloadCollection()
                                }
                                else{
                                    // add the text that we deleted
                                    self.parentVC?.pickedUpBoard?.items.insert(text!, at: destinationIndexPath.row)
                                }
                            }
                            
                        }
                        else{
                            // remove the insert text
                            self.board?.items.remove(at: destinationIndexPath.row)
                        }
                        self.tableView.reloadData()
                    }
                    print("move task")
                    break
                    
                    
                case (nil, nil):
                    // Insert data from a table to another table
                    print("bug")
                    let text = self.parentVC?.pickedUpBoard?.items[self.parentVC!.pickedUpIndex!]
                    self.board?.items.insert(text!, at: self.parentVC!.pickedUpIndex!)
                    Database.setBoard(board: self.board!) { (success) in
                        if success!{
                            // now remove data from source data base
                            self.parentVC?.pickedUpBoard?.items.remove(at: self.parentVC!.pickedUpIndex!)
                            Database.setBoard(board: (self.parentVC?.pickedUpBoard!)!) { (success) in
                                if success! {
                                    self.parentVC!.reloadCollection()
                                }
                                else{
                                    // add the text that we deleted
                                    self.parentVC?.pickedUpBoard?.items.insert(text!, at: self.parentVC!.pickedUpIndex!)
                                }
                            }
                        }
                        else{
                            
                        }
                        self.tableView.reloadData()
                    }
                    break
                    
                default: break
                    
                }
            }
        }
    }
    
    func removeSourceTableData(localContext: Any?) {
        if let (dataSource, sourceIndexPath, tableView) = localContext as? (Board, IndexPath, UITableView) {
            tableView.beginUpdates()
            dataSource.items.remove(at: sourceIndexPath.row)
            tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
}
