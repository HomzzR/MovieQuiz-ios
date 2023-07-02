import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func prepareViewForNextQuestion()
    func prepareViewAfterAnswer(isCorrectAnswer: Bool)
    func showFinalResults()
    func showErrorNetwork(message: String)
    func toggleButton(_ state: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Private properties & IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        presenter.reloadGame()
    }
    
    // MARK: - Functions
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func prepareViewForNextQuestion() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = UIImage()
        textLabel.text?.removeAll()
    }
    
    func prepareViewAfterAnswer(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = ( isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor )
    }
    
    func toggleButton(_ state:Bool) {
        yesButton.isEnabled = state
        noButton.isEnabled = state
    }
    
    func showFinalResults() {
        let result = presenter.makeResults()
        let alertModel = AlertModel(
            title: result.title,
            text: result.text,
            buttonText: result.buttonText,
            completion: { [weak presenter ] in
                presenter?.restartGame()
            }
        )
        alertPresenter?.requestAler(for: alertModel)
    }
    
    func showErrorNetwork(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            text: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.reloadGame()
            })
        alertPresenter?.requestAler(for: model)
    }
    
    // MARK: - Private IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.didAsnwer(isYes: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.didAsnwer(isYes: true)
    }
}

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
}
