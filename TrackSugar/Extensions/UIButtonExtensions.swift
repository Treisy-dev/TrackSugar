import UIKit

extension UIButton {
    func addAlphaAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.5
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.alpha = 1
            }
        })
    }
}
