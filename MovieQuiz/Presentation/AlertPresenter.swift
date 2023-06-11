import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    private var alert: AlertModel?

func requestAler(for model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) { _ in
                model.completion()
            }
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
