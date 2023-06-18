import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func didReceiveAlert(for model: AlertModel?)
}
