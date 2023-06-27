import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
