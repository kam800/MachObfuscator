import Cocoa
import SampleMacAppViewModel

class ViewController: NSViewController {

    let viewModel = ViewModel()

    @IBOutlet weak var counterLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        counterLabel.stringValue = viewModel.counterText
        viewModel.delegate = self
    }

    @IBAction func didTapIncrement(_ sender: NSButton) {
        viewModel.increment()
    }
}

extension ViewController: ViewModelDelegate {
    func viewModelDidChange(counterText: String) {
        counterLabel.stringValue = counterText
    }
}
