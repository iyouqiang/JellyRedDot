//
//  QQBtn.h
//  QQMessageBtn
//
//  Created by ecaray_miss on 2017/12/20.
//  Copyright © 2017年 Miel_TDQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQBtn : UIButton

/**大圆与小圆的断开时的距离 */
@property (nonatomic,assign)CGFloat maxDistance;
/**btn销毁的动画图片组 */
@property (nonatomic,strong)NSMutableArray *images;

@end
