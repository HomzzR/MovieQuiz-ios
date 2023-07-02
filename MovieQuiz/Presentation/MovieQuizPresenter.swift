import UIKit

final class MovieQuizPresenter {
    // MARK: - Properties
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?
    private var quizResults: QuizResultsViewModel?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol?) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
    }
        
    // MARK: - Functions
    
    func didAsnwer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        prepareQuestion()
    }
    
    func reloadGame() {
        questionFactory?.loadData()
        restartGame()
    }
    
    func makeResults() -> QuizResultsViewModel {
        QuizResultsViewModel(
            title: "Этот раунд окончен",
            text: makeResultsMessage(),
            buttonText: "Сыграть еще раз")
    }
    
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // MARK: - Private functions
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
        prepareQuestion()
    }
    
    private func prepareQuestion() {
        viewController?.showLoadingIndicator()
        viewController?.prepareViewForNextQuestion()
        questionFactory?.requestNewQuestion()
    }
    
    private func makeAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.prepareViewAfterAnswer(isCorrectAnswer: isCorrect)
        viewController?.toggleButton(false)
        makeAnswer(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            storeResults()
            viewController?.showFinalResults()
        } else {
            switchToNextQuestion()
        }
    }
    
    private func storeResults() {
        guard let statisticService = statisticService else {
            return
        }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
    }
    
    private func makeResultsMessage() -> String {
        guard let statisticService = statisticService,
              let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
}

// MARK: - Delegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        questionFactory?.requestNewQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            viewController?.hideLoadingIndicator()
            viewController?.toggleButton(true)
            viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showErrorNetwork(message: error.localizedDescription)
    }
}
