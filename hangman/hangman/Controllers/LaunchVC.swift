
import UIKit
import CoreData
import CLTypingLabel

class LaunchVC: UIViewController, WordManagerDelegate {
        
    let titleLabel = CLTypingLabel()
    var titleWord = "HANGMAN"
    
    // to save & read from CoreData
    var mySavedGuessedCoreData = [SavedGuessed]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var wordDirector = WordDirector()
    
    
    override func viewWillAppear(_ animated: Bool) {
        // sets title properties
        titleLabel.textColor = UIColor(hex: Constants.red)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 45)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: Constants.creme)
        
        // reads CoreData
        readFromContext()
        
        // sets cocoapod (the way the title shows)
        titleLabel.charInterval = 0.2
        titleLabel.text = titleWord
        titleLabel.onTypingAnimationFinished = {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
                self.performSegue(withIdentifier: "toGame", sender: nil)
            }
        }
        
        //check what coreData contains and makes performRequest if needed
        wordDirector.delegate = self
        DispatchQueue.global(qos: .userInteractive).async {
            let allFalse = self.mySavedGuessedCoreData.compactMap({$0.guessed == false})
            if allFalse.count < 2 { for _ in 0..<2 { self.wordDirector.performRequest() } }
        }
    }
    
    
    // sends data to GameVC if segue executes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame" {
            if let GameVC = segue.destination as? GameVC {
                GameVC.mySavedGuessedCoreData = mySavedGuessedCoreData
            }
        }
    }



// MARK: - Uploading data from url
    
    func didUpdateWord(_ WordDirector: WordDirector, wordAndDefinitionFromWeb: WordModel) {
        let objectFromEntity = SavedGuessed(context: context)
        objectFromEntity.keyWord = wordAndDefinitionFromWeb.word
        objectFromEntity.definitionKeyWord = wordAndDefinitionFromWeb.definition
        objectFromEntity.guessed = false
        
        mySavedGuessedCoreData.append(objectFromEntity)
        saveToContext()
    }
    
    func didFailedWithError(error: Error) { print(error) }




// MARK: - CoreData: saving and loading

    func saveToContext(){
        DispatchQueue.main.async {
            do { try self.context.save() } catch { print("ERROR: \(error)") }
        }
    }
    func readFromContext() {
            do { self.mySavedGuessedCoreData = try context.fetch(SavedGuessed.fetchRequest()) } catch { print("ERROR: \(error)") }
    }
}


