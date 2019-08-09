import Cocoa
import SampleMacAppViewModel

class ViewController: NSViewController {
    let viewModel = ViewModel()

    @IBOutlet var counterLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        counterLabel.stringValue = viewModel.counterText
        viewModel.delegate = self
    }

    @IBAction func didTapIncrement(_: NSButton) {
        viewModel.increment()
    }
}

extension ViewController: ViewModelDelegate {
    func viewModelDidChange(counterText: String) {
        counterLabel.stringValue = counterText
    }
}
