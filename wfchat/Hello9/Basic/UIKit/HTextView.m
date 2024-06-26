//
//  HTextView.m
//  Hello9
//
//  Created by Ada on 2024/6/26.
//

#import "HTextView.h"

@interface HTextView  ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation HTextView

+ (instancetype)textViewUsingTextLayoutManager:(BOOL)usingTextLayoutManager API_AVAILABLE(ios(16.0), tvos(16.0))  {
    HTextView *textView = [super textViewUsingTextLayoutManager:usingTextLayoutManager];
    [textView didInitialize];
    return textView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {

    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.font = [UIFont systemFontOfSize:16];
    self.placeholderLabel.textColor = [UIColor colorNamed:@"themeGray4"];
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.backgroundColor = UIColor.clearColor;
    
    [self addSubview:self.placeholderLabel];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)textDidChanged:(id)sender {
    NSString *text = self.text;
    if (text == NULL || text.length == 0) {
        text = self.attributedText.string;
    }
    self.placeholderLabel.hidden = !(text == NULL || text.length == 0);
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = font;
    [self setNeedsDisplay];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    _placeholderTextColor = placeholderTextColor;
    self.placeholderLabel.textColor = placeholderTextColor;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    self.placeholderLabel.hidden = text && text.length > 0;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    self.placeholderLabel.hidden = attributedText && attributedText.length > 0;
}

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText {
    self.placeholderLabel.attributedText = placeholderAttributedText;
}

- (NSAttributedString *)placeholderAttributedText {
    return self.placeholderLabel.attributedText;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect labelFrame = self.placeholderLabel.frame;
    labelFrame.origin.y = self.textContainerInset.top;
    // 4.0是光标的left
    labelFrame.origin.x = self.textContainerInset.left + 4.0f;
    labelFrame.size.width = self.frame.size.width - labelFrame.origin.x;
    self.placeholderLabel.frame = labelFrame;
    [self.placeholderLabel sizeToFit];
}

@end
