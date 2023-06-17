import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Private properties & IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0                                       
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        
        resetRound()
        
        /// ПЕСОЧНИЦА И БАНДЛ
        
        print(NSHomeDirectory())                                                                     // Песочница
        UserDefaults.standard.set(true, forKey: "viewDidLoad")
        print(Bundle.main.bundlePath)                                                                // Бандл
        print("___________")
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)         // Адрес папки Documents в песочнице
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsURL)
        let fileName = "text.swift"
        documentsURL.appendPathComponent(fileName)
        print(documentsURL)
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            let hello = "Hello world!"
            let data = hello.data(using: .utf8)
            FileManager.default.createFile(atPath: documentsURL.path, contents: data)
        }
        try? print(String(contentsOf: documentsURL))
    }
    
    // MARK: - Functions
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func resetRound() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNewQuestion()
    }
    
    // MARK: - Private functions
    
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func showAnswerOrResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =  isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        toggleButton(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.toggleButton(true)
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз",
                completion: resetRound)
            
            alertPresenter?.requestAler(for: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNewQuestion()
        }
    }
    
    private func toggleButton(_ state:Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
    
    // MARK: - Private IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerOrResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerOrResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
