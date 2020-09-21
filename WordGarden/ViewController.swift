//
//  ViewController.swift
//  WordGarden
//
//  Created by Marissa D'Antonio on 9/20/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var wordsGuessedLabel: UILabel!
    @IBOutlet weak var wordsRemainingLabel: UILabel!
    @IBOutlet weak var wordsMissedLabel: UILabel!
    @IBOutlet weak var wordsInGameLabel: UILabel!
    
    
    @IBOutlet weak var wordBeingRevealedLabel: UILabel!
    @IBOutlet weak var guessedLetterTextField: UITextField!
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusMessageLabel: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    var wordsToGuess = ["SWIFT","DOG","CAT"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongGuessesRemaining = 8
    var wordsGuessedCount = 0
    var wordsMissedcount = 0
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = guessedLetterTextField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
        wordBeingRevealedLabel.text = " _" + String(repeating: " _", count: wordToGuess.count)
        updateGameStatusLabels()
    }
    
    func updateUIAfterGuess(){
        guessedLetterTextField.resignFirstResponder()
        guessedLetterTextField.text! = ""
        guessLetterButton.isEnabled = false
    }
    func formatRevealedWord (){
        var revealedWord = ""
        for letter in wordToGuess {
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter)"
            } else {
                revealedWord = revealedWord + " _"
            }
        }
        revealedWord.removeLast()
        wordBeingRevealedLabel.text = revealedWord
    }
    
    func updateAfterWinOrLose() {
        currentWordIndex += 1
        guessedLetterTextField.isEnabled = false
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = false
        
        updateGameStatusLabels()
    }
    
    func updateGameStatusLabels(){
        wordsGuessedLabel.text = "Words Guessed: \(wordsGuessedCount)"
        wordsMissedLabel.text = "Words Missed: \(wordsMissedcount)"
        wordsRemainingLabel.text = "Words to Guess: \(wordsToGuess.count - (wordsGuessedCount + wordsMissedcount))"
        wordsInGameLabel.text = "Words in Gmae: \(wordsToGuess.count)"
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed: String){
        if wordToGuess.contains(currentLetterGuessed) == false {
            wrongGuessesRemaining = wrongGuessesRemaining - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                UIView.transition(with: self.flowerImageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {self.flowerImageView.image =
                                    UIImage(named:
                                    "wilt \(self.wrongGuessesRemaining)")})
                { (_) in
                    if self.wrongGuessesRemaining != 0{
                        self.flowerImageView.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")
                    }else{
                        self.playSound(name: "word-notguessed")
                        UIView.transition(with: self.flowerImageView,
                                          duration: 0.5,
                                          options: .transitionCrossDissolve,
                                          animations: {self.flowerImageView.image =
                                            UIImage(named:
                                            "flower \(self.wrongGuessesRemaining)")})
                    }
                    
                    
                }
                
                self.playSound(name: "incorrect")
            }
        } else {
            playSound(name: "correct")
        }
    }
    
    func guessALetter() {
        // get current letter guessed and add it to all lettersGuessed
        let currentLetterGuessed = guessedLetterTextField.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        
        formatRevealedWord()
        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)

        guessCount += 1
//        var guesses = "Guesses"
//        if  guessCount == 1 {
//            guesses = "Guess"
//        }
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessageLabel.text = "You've Made \(guessCount) \(guesses)"
        
        if wordBeingRevealedLabel.text!.contains("_") == false {
            gameStatusMessageLabel.text = "You've guessed it! It took you \(guessCount) guesses to guess the word."
            wordsGuessedCount += 1
            playSound(name: "word-guessed")
            updateAfterWinOrLose()
        } else if wrongGuessesRemaining == 0 {
            gameStatusMessageLabel.text = "So sorry. You're all out of guesses."
            wordsGuessedCount += 1
            playSound(name: "word-not-guessed")
            updateAfterWinOrLose()
        }
        if currentWordIndex == wordsToGuess.count {
            gameStatusMessageLabel.text! += "\n\nYou've tired all of the words! Restart from the beginning?"
        }
    }
    
    func playSound(name: String){
        if let sound = NSDataAsset(name: name){
                 do {
                     try audioPlayer = AVAudioPlayer(data: sound.data)
                     audioPlayer.play()
                 } catch {
                     print("ERROR: \(error.localizedDescription)could not initialize AVAudioPlayer object.")
                 }
             } else {
                     print("ERROR: could not read data from te file sound")
             }
    }
    
    @IBAction func guessedLetterFieldChanged(_ sender: UITextField) {
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        updateUIAfterGuess()
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        updateUIAfterGuess()
    }
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        if currentWordIndex == wordToGuess.count {
            currentWordIndex = 0
            wordsGuessedCount = 0
            wordsMissedcount = 0
        }
        
        playAgainButton.isHidden = true
        guessedLetterTextField.isEnabled = true
        guessLetterButton.isEnabled = false
        wordToGuess = wordsToGuess[currentWordIndex]
        wrongGuessesRemaining = maxNumberOfWrongGuesses
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count - 1)
        guessCount = 0
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        lettersGuessed = ""
        updateGameStatusLabels()
        gameStatusMessageLabel.text = "You've Made Zero GUesses"
    }
    
    
}

