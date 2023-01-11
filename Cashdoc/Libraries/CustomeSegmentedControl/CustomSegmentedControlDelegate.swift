import UIKit

public protocol CustomSegmentedControlDelegate: AnyObject {
    func changeToIndex(index: Int)
}

public class CustomSegmentedControl: UIView {
    
    // MARK: - Properties
    
    var textColor: UIColor = .black
    var selectorViewColor: UIColor = .red
    var selectorTextColor: UIColor = .red
    var animatedDuration: TimeInterval = 0.25
    
    public private(set) var selectedIndex: Int = 0
    
    weak var delegate: CustomSegmentedControlDelegate?
    
    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectorView: UIView!
    
    // MARK: - Con(De)structor
    
    init(buttonTitles: [String]) {
        super.init(frame: .zero)
        
        self.buttonTitles = buttonTitles
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIView
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
        setIndex(index: selectedIndex)
    }
    
    // MARK: - Public methods
    
    public func getButtonsCount() -> Int {
        return self.buttons.count
    }
    
    public func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        updateView()
    }
    
    public func setIndex(index: Int, _animation: Bool = false) {
        DispatchQueue.main.async {
            self.buttons.forEach({ $0.setTitleColor(self.textColor, for: .normal) })
            let button = self.buttons[index]
            self.selectedIndex = index
            button.setTitleColor(self.selectorTextColor, for: .normal)
            let selectorPosition = self.frame.width/CGFloat(self.buttonTitles.count) * CGFloat(index)
            if _animation {
                UIView.animate(withDuration: self.animatedDuration) {
                    self.selectorView.frame.origin.x = selectorPosition
                }
            } else {
                self.selectorView.frame.origin.x = selectorPosition
            }
            
        }
    }
    
    // MARK: - Private methods
    
    private func updateView() {
        func createButton() {
            buttons = [UIButton]()
            subviews.forEach { $0.removeFromSuperview() }
            for buttonTitle in buttonTitles {
                let button = UIButton(type: .system)
                button.setTitle(buttonTitle, for: .normal)
                button.addTarget(self, action: #selector(CustomSegmentedControl.buttonAction(sender:)), for: .touchUpInside)
                button.setTitleColor(textColor, for: .normal)
                buttons.append(button)
            }
            buttons.first?.setTitleColor(selectorTextColor, for: .normal)
        }
        func configSelectorView() {
            let selectorWidth = frame.width / CGFloat(buttonTitles.count)
            selectorView = UIView(frame: CGRect(x: 0, y: frame.height-2, width: selectorWidth, height: 2))
            selectorView.backgroundColor = selectorViewColor
            addSubview(selectorView)
        }
        func configStackView() {
            let stack = UIStackView(arrangedSubviews: buttons)
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fillEqually
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        createButton()
        configSelectorView()
        configStackView()
    }
    
    func topLineSelectorView(isTopLine: Bool) {
        if isTopLine == true {
            DispatchQueue.main.async {
                self.selectorView.frame.origin.y = 0
            }
        }
    }
    
    // MARK: - Private selector
    
    @objc private func buttonAction(sender: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == sender {
                let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                selectedIndex = buttonIndex
                delegate?.changeToIndex(index: selectedIndex)
                UIView.animate(withDuration: animatedDuration) {
                    self.selectorView.frame.origin.x = selectorPosition
                }
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
    }
    
}
