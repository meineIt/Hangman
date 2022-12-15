
import UIKit
import CoreData

class GameVC: UIViewController, WordManagerDelegate {

    // to save & read from CoreData
    var mySavedGuessedCoreData = [SavedGuessed]()
    var wordDirector = WordDirector()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    let lifes = UILabel()
    var lifesNumber = 5 { didSet { lifes.text = "Lifes: \(lifesNumber)" } }
    let score = UILabel()

    
    let passwordTip = UILabel()
    let passwordLabel = UILabel()
    var currentPassword = String()
    var hiddenPassword = String() { didSet { passwordLabel.text = "\(hiddenPassword)" } }

    
    let alphabetKeyboard = UIView()
    var pressedButtons = [UIButton]()
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUWVXYZ".map{String($0)}



// MARK: - Creates layout for main view
    override func viewWillAppear(_ animated: Bool) {

        // sets color and adds to view elements of array belowe
        for i in [score, lifes, passwordTip, passwordLabel] {
            
            i.textColor = UIColor(hex: Constants.red)
            i.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(i)
        }

        // sets el. of array to be ready to show as many letters as the word has (even in two lines)
        for i in [passwordLabel, passwordTip] {
            i.numberOfLines = 0
            i.textAlignment = .center
        }

        // sets font type as system
        passwordTip.font = UIFont.systemFont(ofSize: 20)
        passwordLabel.font = UIFont.boldSystemFont(ofSize: 30)

        
        alphabetKeyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alphabetKeyboard)

        
        // creates alphabet buttons
        var letterNo = 0
        outerLoop: for height in 0..<7 {
            for width in 0..<4 {
                let button = UIButton()
                button.frame = CGRect(x: (width * 90), y: (height * 70), width: 90, height: 70)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                button.setTitleColor(UIColor(hex: Constants.red), for: .normal)
                button.setTitle(alphabet[letterNo], for: .normal)
                button.addTarget(self, action: #selector(letterPressed), for: .touchUpInside)
                alphabetKeyboard.addSubview(button)
                if letterNo == alphabet.count - 1 { break outerLoop } else { letterNo += 1 }
            }
        }

        //sets constraints for all objct on screen
        NSLayoutConstraint.activate([
            score.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            score.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),

            lifes.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lifes.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),

            passwordTip.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTip.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            passwordTip.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            passwordTip.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),

            passwordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordLabel.topAnchor.constraint(equalTo: passwordTip.topAnchor, constant: 90),
            passwordLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            passwordLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),

            alphabetKeyboard.heightAnchor.constraint(equalToConstant: 490),
            alphabetKeyboard.widthAnchor.constraint(equalToConstant: 360),
            alphabetKeyboard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alphabetKeyboard.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 0)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: Constants.creme)
        wordDirector.delegate = self
        
        // this func starts the game
        launchPassword()
    }


    
    
    
    // MARK: - Uses data from coreData
    // performs request (url) if it is necessary

    @objc func launchPassword() {
        
        // performs request
        DispatchQueue.global(qos: .utility).async {
            
            // creates array of passwords which are not guessed
            let allFalse = self.mySavedGuessedCoreData.compactMap({$0.guessed}).filter({$0 != true})
            // counts how many password is not guessed
            if allFalse.count < 100 { for _ in 0...10 { self.wordDirector.performRequest() } }
            
        }
        
        self.hiddenPassword.removeAll()

        // puts coreData on the screen
        DispatchQueue.main.async {
            
            if !self.mySavedGuessedCoreData.isEmpty {
                
                // shuffles the album of passwords [cause without shuffling if user not guess the password then he gets the same password :)]
                self.mySavedGuessedCoreData.shuffle()
                for data in self.mySavedGuessedCoreData {
                    if !data.guessed {
                        self.passwordTip.text = data.definitionKeyWord
                        self.currentPassword = data.keyWord ?? "Password not loaded."
                        for _ in 0..<self.currentPassword.count { self.hiddenPassword += "_  " }
                        print("currentPassword:", self.currentPassword)
                        break
                    }
                }
                
            } else {
                self.passwordTip.text = "Error \n No internet connection."
                self.hiddenPassword = ""
            }
            
            // counts how many passwords is not guessed and shows the number in score.text view
            let allTrue = self.mySavedGuessedCoreData.compactMap({$0.guessed}).filter({$0 != false})
            self.score.text = "Guessed: \(allTrue.count)"
        }
            
        // makes all keyboard-buttons not hidden
        for i in self.pressedButtons {
            UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
                       animations: {
                    i.alpha = 1.0
            }) { (finished: Bool) in
                i.isEnabled = true
            }
        }
        
        pressedButtons.removeAll()
    }
    
    
    
    // MARK: - Alphabet button is pressed
    
    @objc func letterPressed(_ sender: UIButton) {
        
        // checks if the currentPassword contains pressed letter. Changes hiddenPassword if contains
        DispatchQueue.main.async {
            
            if let button = sender.titleLabel!.text {

                var hiddenArr = self.hiddenPassword.map({String($0)}).filter({$0 != " "})
                var isLetterGuessed = false
                
                for (index, letter) in self.currentPassword.map({$0}).enumerated() {
                    if letter.uppercased() == button {
                        hiddenArr[index] = button
                        isLetterGuessed = true
                    }
                }
                
                if !isLetterGuessed { self.lifesNumber -= 1 }
                self.hiddenPassword = hiddenArr.joined(separator: "  ")
                
                UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
                        sender.alpha = 0.0
                }) { (finished: Bool) in
                    sender.isEnabled = false
                }
                    
                self.pressedButtons.append(sender)
                
            }
            
            
            // works if the user input is equal to currentPassword
            if self.hiddenPassword.uppercased().filter({$0 != " "}) == self.currentPassword.uppercased() {
                
                self.setTrueGuessedWord(self.currentPassword)
                
                let alert = UIAlertController(title: "Great!", message: "You guessed the word! \(Constants.temptationList.randomElement() ?? "")", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Next word", style: .default, handler: self.getNextPassword))
                alert.addAction(UIAlertAction(title: "Show guessed", style: .default, handler: self.showGuessedTableView))
                self.present(alert, animated: true, completion: nil)
            }
            
            // works if user lost all of his lifes
            if self.lifesNumber == 0 {
                
                self.lifesNumber = 5
                let alert = UIAlertController(title: "Lost", message: "The word to be guessed was \(self.currentPassword)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Next word", style: .default, handler: self.getNextPassword))
                alert.addAction(UIAlertAction(title: "Show guessed", style: .default, handler: self.showGuessedTableView))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }



// MARK: - Actions when a word is not/guessed

    func getNextPassword(action: UIAlertAction) { launchPassword()}

    
    func showGuessedTableView(action: UIAlertAction) {
        performSegue(withIdentifier: "toExplanation", sender: nil)
        launchPassword()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExplanation" {
            let ExplanationVC = segue.destination as! ExplanationVC
            ExplanationVC.mySavedGuessedCoreData = mySavedGuessedCoreData
        }
    }
    
    
    // sets "guessed" property in coreData to TRUE if the word is guessed (so this word ish shown in the tableView)
    func setTrueGuessedWord(_ currentPassword: String) {
        for data in mySavedGuessedCoreData {
            if data.keyWord == currentPassword {
                data.guessed = true
                break
            }
        }
            saveToContext()
        }



// MARK: - puts data from request to coreData
    
    func didUpdateWord(_ WordDirector: WordDirector, wordAndDefinitionFromWeb: WordModel) {
        DispatchQueue.main.async {
            let objectFromEntity = SavedGuessed(context: self.context)
            objectFromEntity.keyWord = wordAndDefinitionFromWeb.word
            objectFromEntity.definitionKeyWord = wordAndDefinitionFromWeb.definition
            objectFromEntity.guessed = false
            
            self.mySavedGuessedCoreData.append(objectFromEntity)
            self.saveToContext()
        }
    }
    
    func didFailedWithError(error: Error) { print(error) }


    
// MARK: - CoreData: saving & reading
    
    func saveToContext() {
        DispatchQueue.main.async {
            do { try self.context.save() } catch { print("SAVING TO CONTEXT - ERROR: \(error)") }
            }
        }
    func readFromContext() {
            do { self.mySavedGuessedCoreData = try context.fetch(SavedGuessed.fetchRequest()) } catch { print("READING FROM CONTEXT ERROR: \(error)") }
    }
}
