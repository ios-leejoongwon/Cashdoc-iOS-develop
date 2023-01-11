import UIKit

private var touchProxyContext: UInt8 = 0
private var normalBorderColorContext: UInt8 = 0
private var normalBorderWidthContext: UInt8 = 0
private var highlightingBorderColorContext: UInt8 = 0
private var highlightingBorderWidthContext: UInt8 = 0

public extension Highlighting where Base: UITextField {
    
    // MARK: - Properties
    
    private var touchProxy: TouchProxy? {
        get {
            return objc_getAssociatedObject(base, &touchProxyContext) as? TouchProxy
        }
        set {
            objc_setAssociatedObject(base, &touchProxyContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var normalBorderColor: UIColor? {
        get {
            return objc_getAssociatedObject(base, &normalBorderColorContext) as? UIColor
        }
        set {
            objc_setAssociatedObject(base, &normalBorderColorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var normalBorderWidth: CGFloat? {
        get {
            return objc_getAssociatedObject(base, &normalBorderWidthContext) as? CGFloat
        }
        set {
            objc_setAssociatedObject(base, &normalBorderWidthContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var highlightingBorderColor: UIColor? {
        get {
            return objc_getAssociatedObject(base, &highlightingBorderColorContext) as? UIColor
        }
        set {
            objc_setAssociatedObject(base, &highlightingBorderColorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var highlightingBorderWidth: CGFloat? {
        get {
            return objc_getAssociatedObject(base, &highlightingBorderWidthContext) as? CGFloat
        }
        set {
            objc_setAssociatedObject(base, &highlightingBorderWidthContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Public methods
    
    func enable(normalBorderColor: UIColor? = nil, highlightingBorderColor: UIColor = UIColor(red: 0.0/255.0, green: 144.0/255.0, blue: 255.0/255.0, alpha: 1.0), normalBorderWidth: CGFloat = 1.0, highlightingBorderWidth: CGFloat = 1.0) {
        disableHighlighting()
        
        self.normalBorderColor = normalBorderColor
        self.normalBorderWidth = normalBorderWidth
        self.highlightingBorderColor = highlightingBorderColor
        self.highlightingBorderWidth = highlightingBorderWidth
        
        touchProxy = TouchProxy(textField: base)
        touchProxy?.addTarget()
        
        if let normalBorderColor = normalBorderColor {
            base.layer.borderColor = normalBorderColor.cgColor
            base.layer.borderWidth = normalBorderWidth
        }
    }
    
    func disableHighlighting() {
        normalBorderColor = nil
        normalBorderWidth = nil
        highlightingBorderColor = nil
        highlightingBorderWidth = nil
        
        touchProxy = nil
        touchProxy?.removeTarget()
    }
    
    // MARK: - Proxy
    
    fileprivate final class TouchProxy {
        
        // MARK: - Properties
        
        private let textField: UITextField
        
        // MARK: - Constructor
        
        init(textField: UITextField) {
            self.textField = textField
        }
        
        // MARK: - Public methods
        
        public func addTarget() {
            textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        }
        
        public func removeTarget() {
            textField.removeTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
            textField.removeTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
        }
        
        // MARK: - Private methods
        
        private func updateBorder(enable: Bool) {
            guard enable else {
                textField.layer.borderColor = textField.highlighting.normalBorderColor?.cgColor ?? nil
                textField.layer.borderWidth = textField.highlighting.normalBorderWidth ?? 0
                return
            }
            
            guard let borderColor = textField.highlighting.highlightingBorderColor, let borderWidth = textField.highlighting.highlightingBorderWidth else {return}
            textField.layer.borderColor = borderColor.cgColor
            textField.layer.borderWidth = borderWidth
        }
        
        // MARK: - Private selector
        
        @objc private func editingDidBegin(_ textField: UITextField) {
            updateBorder(enable: true)
        }
        
        @objc private func editingDidEnd(_ textField: UITextField) {
            updateBorder(enable: false)
        }
        
    }
    
}
