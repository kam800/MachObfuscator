import Foundation
import SampleIosAppModel

public protocol ViewModelDelegate: class {
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
        self.observation = self.model.observe(\SampleModel.counter, options:.initial) { [weak self] (model, change) in
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
