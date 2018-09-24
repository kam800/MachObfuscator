import UIKit
import SampleIosAppViewModel

class ViewController: UIViewController {

    let viewModel = ViewModel()

    @IBOutlet weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        counterLabel.text = viewModel.counterText
        viewModel.delegate = self
    }

    @IBAction func didTapIncrement(_ sender: UIButton) {
        viewModel.increment()
    }
}

extension ViewController: ViewModelDelegate {
    func viewModelDidChange(counterText: String) {
        counterLabel.text = counterText
    }
}
