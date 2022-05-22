//
//  ContentView.swift
//  WordScramble
//
//  Created by Mark Perryman on 5/18/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    // Alerts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    @State private var gameScore = 0

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }

                Section {
                    HStack {
                        Spacer()

                        Text("\(gameScore)")
                            .font(.largeTitle)

                        Spacer()
                    }
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Text(word)
                            Image(systemName: "\(word.count).circle")
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { startGame() }, label: {
                        Text("New Game")
                    })
                }
            }
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    func addNewWord() {
        let anwser = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard anwser.count > 0 else { return }

        guard isOriginal(word: anwser) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: anwser) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }

        guard isReal(word: anwser) else {
            wordError(title: "Word not recognized", message: "You can't just make them up")
            return
        }

        guard isWordMoreThanThreeCharacters(word: anwser) else {
            wordError(title: "Word not long enough", message: "You can't enter words with less than 3 characters")
            return
        }

        // More Validation
        withAnimation {
            usedWords.insert(anwser, at: 0)
        }
        newWord = ""
        calculateScore(word: anwser)
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"

                usedWords.removeAll()

                gameScore = 0
                
                return
            }
        }

        fatalError("Could not load start.txt from the bundle")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func isWordMoreThanThreeCharacters(word: String) -> Bool {
        word.utf16.count >= 3
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError.toggle()
    }

    func calculateScore(word: String) {
        gameScore += word.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
