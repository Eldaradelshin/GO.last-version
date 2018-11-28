import UIKit
//swiftlint:disable weak_delegate

/// Управляет логикой перемещения контейнера
class ContainerViewManager: NSObject {
    
    // Высота серчБара
    let heightSearchBar: CGFloat = 80
    
    var view: UIView!
    var constraint: NSLayoutConstraint!
    weak var delegate: BuildRoute?
    
    var top: CGFloat = 0
    var middle: CGFloat = 0
    var lower: CGFloat = 0
    
    // MARK: - Вычисление позиций
    
    func calculatePositions() {
        
        top = self.view.bounds.minY
        middle = (self.view.bounds.height * 2 / 3).rounded()
        
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.maxY
        lower = height - (view.safeAreaInsets.bottom + heightSearchBar)
    }
    
    
    // MARK: - Анимация
    
    // Перемещает контейнер на следующую позицию по направлению жеста
    func moveContainer(direction: UISwipeGestureRecognizer.Direction,
                       heightConstraint: CGFloat) {
        
        var position: CGFloat
        
        if heightConstraint == middle {
            
            if direction == .up {
                position = top
            } else {
                position = lower
            }
        } else {
            
            if heightConstraint == top {
                delegate?.buldRoute()
            }
            
            position = middle
        }
        
        animate(to: position)
    }
    
    // Анимирует констрейнт контейнера
    func animate(to: CGFloat) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.constraint.constant = to
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
