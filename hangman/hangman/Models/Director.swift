
import Foundation

protocol WordManagerDelegate {
    func didUpdateWord(_ wordDirector: WordDirector, wordAndDefinitionFromWeb: WordModel)
    func didFailedWithError(error: Error)
}


struct WordDirector {
    var delegate: WordManagerDelegate?
    
    func performRequest() {
        if let url = URL(string: "https://random-words-api.vercel.app/word/"){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailedWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let wordAndDefinitionFromWeb = self.rozbiórJSON(safeData){
                        self.delegate?.didUpdateWord(self, wordAndDefinitionFromWeb: wordAndDefinitionFromWeb)}
                }
            }
            task.resume()
        }
    }
    
    
    func rozbiórJSON(_ dataWord: Data) -> WordModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([WordDecoder].self, from: dataWord)
            let word = (decodedData[0].word)
            let definition = (decodedData[0].definition)
            
            let wordAndDefinitionFromWeb = WordModel(word: word, definition: definition)
            return wordAndDefinitionFromWeb
            
        } catch {
            delegate?.didFailedWithError(error: error)}
        return nil}
}

