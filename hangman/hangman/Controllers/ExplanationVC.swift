
import UIKit

class ExplanationVC: UITableViewController {

    var mySavedGuessedCoreData = [SavedGuessed]()
    var onlyGuessed = [SavedGuessed]()
    let emptyListGuessed = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: Constants.lightGray)
        tableView.backgroundColor = UIColor(hex: Constants.lightGray)
        
        // sets the communicate when user have not guessed anything
        if mySavedGuessedCoreData.isEmpty {
            emptyListGuessed.text = "You have not guessed any word so far."
            emptyListGuessed.font = UIFont.systemFont(ofSize: 18)
            emptyListGuessed.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyListGuessed)
            
            NSLayoutConstraint.activate([
                emptyListGuessed.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyListGuessed.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
        
        // creates an array of guessed passwords
        for data in mySavedGuessedCoreData {
            if data.guessed {
                onlyGuessed.append(data)
            }
        }
        
        //puts the newest guessed ones at the top of the tableView
        onlyGuessed.reverse()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // sets colours
        cell.contentView.backgroundColor = UIColor(hex: Constants.lightGray)
        cell.textLabel?.textColor = UIColor(hex: Constants.red)
        cell.detailTextLabel?.textColor = UIColor(hex: Constants.red)
        
        // sets numbers of lines to unlimited
        cell.detailTextLabel?.numberOfLines = 0
        
        // sets system font
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        // assigns data to cell
        cell.textLabel?.text = onlyGuessed[indexPath.row].keyWord
        cell.detailTextLabel?.text = onlyGuessed[indexPath.row].definitionKeyWord
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlyGuessed.count
    }
}

