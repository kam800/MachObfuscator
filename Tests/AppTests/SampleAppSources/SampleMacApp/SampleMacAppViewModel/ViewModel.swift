import Foundation
import SampleMacAppModel

public protocol ViewModelDelegate: AnyObject {
    func viewModelDidChange(counterText: String)
}

public class ViewModel {
    private let model: SampleModel
    private var observation: NSKeyValueObservation?

    public private(set) var counterText: String = "" {
        didSet {
            delegate?.viewModelDidChange(counterText: counterText)
        }
    }

    public weak var delegate: ViewModelDelegate?

    public init(model: SampleModel = SampleModel()) {
        self.model = model
        observation = self.model.observe(\SampleModel.counter, options: .initial) { [weak self] model, _ in
            self?.counterText = String(model.counter)
        }
    }

    deinit {
        observation?.invalidate()
    }

    public func increment() {
        model.increment()
    }
}
