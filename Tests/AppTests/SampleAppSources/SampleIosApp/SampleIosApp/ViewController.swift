import SampleIosAppViewModel
import UIKit

class ViewController: UIViewController {
    let viewModel = ViewModel()

    @IBOutlet var counterLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        counterLabel.text = viewModel.counterText
        viewModel.delegate = self
    }

    @IBAction func didTapIncrement(_: UIButton) {
        viewModel.increment()
    }
}

extension ViewController: ViewModelDelegate {
    func viewModelDidChange(counterText: String) {
        counterLabel.text = counterText
    }
}
