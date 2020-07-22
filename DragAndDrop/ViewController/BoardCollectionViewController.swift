import UIKit
import MobileCoreServices

class BoardCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var boards : [Board] = []
    
    var pickedUpBoard : Board?
    var pickedUpIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        updateCollectionViewItem(with: view.bounds.size)
        
        Database.getUserBoardsData { (arr) in
            if arr != nil {
                for board in arr! {
                    print(board.title)
                    self.boards.append(board)
                }
                 self.collectionView.reloadData()
            }
        }
    }
    
    //MARK:- Helper functions
    private func setupNavigationBar() {
        setupAddButtonItem()
    }
    
    func reloadCollection(){
        collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewItem(with: size)
    }
    
    private func updateCollectionViewItem(with size: CGSize) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = CGSize(width: 225, height: size.height * 0.8)
    }
    
    func setupAddButtonItem() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListTapped(_:)))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func setupRemoveBarButtonItem() {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addInteraction(UIDropInteraction(delegate: self))
        let removeBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = removeBarButtonItem
    }

    @objc func addListTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add List", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {
                return
            }
            let newBoard = Board(title: text, items: [])
            Database.setBoard(board: newBoard) { (success) in
                if success! {
                    self.boards.append(newBoard)
                    let addedIndexPath = IndexPath(item: self.boards.count - 1, section: 0)
                    self.collectionView.insertItems(at: [addedIndexPath])
                    self.collectionView.scrollToItem(at: addedIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                }
                else{
                    // update user cant add board
                    let errorController = UIAlertController (title: "Error", message: "user can't add board",preferredStyle: .alert)
                    self.present(errorController, animated: true)
                }
            }
        
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BoardCollectionViewCell
        
        cell.setup(with: boards[indexPath.item])
        cell.parentVC = self
        return cell
    }
    
}

//MARK:- Extension
extension BoardCollectionViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            session.loadObjects(ofClass: NSString.self) { (items) in
                guard let _ = items.first as? String else {
                    return
                }
                
                if let (dataSource, sourceIndexPath, tableView) = session.localDragSession?.localContext as? (Board, IndexPath, UITableView) {
                    
                    let selectedIndex = sourceIndexPath.row
                    let text = dataSource.items[selectedIndex]
                    
                    dataSource.items.remove(at: selectedIndex)
                    Database.setBoard(board: dataSource) { (success) in
                        if success!{
                            //doing nothing
                        }
                        else{
                            dataSource.items.insert(text, at: selectedIndex)
                        }
                         tableView.reloadData()
                    }
                }
            }
        }
    }
}
