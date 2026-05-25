//
//  EKEventStore.h
//  BACtrackByDreamTeam2
//
//  Created by 鈴木通之 on 2023/12/15.
//

#import <Foundation/Foundation.h>


@interface EKEventStore : NSObject
@property (nonatomic) NSArray *singletonArray;
+ (EKEventStore *)sharedManager;

-(void)setSingletonArray:(NSArray *)array;  //demoMethod
@end
