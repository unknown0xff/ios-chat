import UIKit

// MARK: - Properties
open class HAlertContainerView: UIView {
    
    public var leftButtonTitle: String? {
        didSet {
            leftButton.setTitle(leftButtonTitle, for: .normal)
        }
    }
    
    public var rightButtonTitle: String? {
        didSet {
            rightButton.setTitle(rightButtonTitle, for: .normal)
        }
    }
    
    public var title: String?
    public var attributeTitle: NSAttributedString? {
        didSet {
            titleLabel.attributedText = attributeTitle
        }
    }
    
    public var message: String?
    public var attributeMessage: NSAttributedString? {
        didSet {
            messageLabel.attributedText = attributeMessage
        }
    }
    
    public var customContentView: UIView?
    
    public private(set) var leftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.setTitleColor(UIColor(red: 1, green: 0.227, blue: 0.188, alpha: 1), for: .normal)
        return btn
    }()
    
    public private(set) lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.setTitleColor(UIColor(red: 0, green: 0.46, blue: 1, alpha: 1), for: .normal)
        return btn
    }()
    
    public private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 17)
        return label;
    }()
    public private(set) var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        return label;
    }()
    
    private lazy var container: UIStackView = {
        let stack = UIStackView.init()
        stack.spacing = 16
        stack.alignment = .center
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var buttonContainer: UIStackView = {
        let stack = UIStackView.init()
        stack.spacing = 1
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private lazy var contanerGapLine: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor(red: 0.969, green: 0.976, blue: 0.988, alpha: 1)
        return v
    }()
    
    private lazy var buttonGapLine: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor(red: 0.969, green: 0.976, blue: 0.988, alpha: 1)
        return v
    }()
    
    
    public init(message: String? = nil, title: String? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.message = message
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Method
extension HAlertContainerView {

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        addChildren()
        makeConstraints()
    }
}

// MARK: - Private Method
private extension HAlertContainerView {
    
    func doInitlize() {
        backgroundColor = .white
        layer.cornerRadius = 12
        
        titleLabel.textAlignment = .center
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        
    }
    
    func addTitleLabel() {
        
        if let attibuteTitle = attributeTitle, !attibuteTitle.string.isEmpty {
            titleLabel.attributedText = attributeTitle
            container.addArrangedSubview(titleLabel)
        } else if let title = title, !title.isEmpty {
            titleLabel.text = title
            container.addArrangedSubview(titleLabel)
        }
    }
    
    func addMessageLabel() {
        
        if let attibuteMessage = attributeMessage, !attibuteMessage.string.isEmpty {
            messageLabel.attributedText = attibuteMessage
            container.addArrangedSubview(messageLabel)
        } else if let message = message, !message.isEmpty {
            messageLabel.text = message
            container.addArrangedSubview(messageLabel)
        }
    }
    
    func addChildren() {
        
        doInitlize()
        
        addSubview(container)
        
        addTitleLabel()
        
        if let customContentView = customContentView {
            container.addArrangedSubview(customContentView)
            
            customContentView.snp.remakeConstraints { make in
                make.size.equalTo(customContentView.frame.size)
            }
            
        } else {
            addMessageLabel()
        }
        
        addSubview(buttonContainer)
        if let _ = leftButtonTitle {
            buttonContainer.addArrangedSubview(leftButton)
        }
        if let _ = rightButtonTitle {
            buttonContainer.addArrangedSubview(rightButton)
        }
        if let _ = leftButtonTitle, let _ = rightButtonTitle {
            addSubview(buttonGapLine)
        }
        
        addSubview(contanerGapLine)
    }
    
    func makeConstraints() {
        
        snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(CGFloat(UIScreen.main.bounds.width - 2.0 * kContainerMargin))
            make.height.lessThanOrEqualTo(CGFloat(UIScreen.main.bounds.height-2.0 * kContainerMargin))
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 28, left: 24, bottom: 84, right: 24))
        }
        
        buttonContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kButtonContainerHeight)
        }
        
        contanerGapLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(buttonContainer).offset(-1)
        }

        if let leftTitle = leftButtonTitle, let rightTitle = rightButtonTitle {
            buttonGapLine.snp.makeConstraints { make in
                make.center.equalTo(buttonContainer)
                make.height.equalTo(28)
                make.width.equalTo(1)
            }
        }
    }
}

// MARK: - Constant
fileprivate let kButtonContainerHeight = 56
fileprivate let kContainerMargin = 32.0
