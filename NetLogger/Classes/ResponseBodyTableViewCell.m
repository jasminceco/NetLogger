//
//  ResponseBodyTableViewCell.m
//  NetLogger
//
//  Created by Pankaj Nathani on 11/05/18.
//

#import "ResponseBodyTableViewCell.h"

@implementation ResponseBodyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _detailtextLabel.userInteractionEnabled = YES;
    _titletextLabel.userInteractionEnabled = YES;
UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textPressed:)];
    [_titletextLabel addGestureRecognizer:tap];
    [_titletextLabel addGestureRecognizer:longPress];
    [_detailtextLabel addGestureRecognizer:tap];
    [_detailtextLabel addGestureRecognizer:longPress];
}
 
- (void) textPressed:(UILongPressGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized &&
        [gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        UILabel *someLabel = (UILabel *)gestureRecognizer.view;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:someLabel.text];
        //let the user know you copied the text to the pasteboard and they can no paste it somewhere else
        
    }
}
 
- (void) textTapped:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized &&
        [gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        NSLog(@"fjeeddfj");
        UILabel *someLabel = (UILabel *)gestureRecognizer.view;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:someLabel.text];
        //let the user know you copied the text to the pasteboard and they can no paste it somewhere else
    }
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
