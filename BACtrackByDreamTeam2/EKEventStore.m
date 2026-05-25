//
//  EKEventStore.m
//  BACtrackByDreamTeam2
//
//  Created by 鈴木通之 on 2023/12/15.
//

#import <Foundation/Foundation.h>
#import "EKEventStore.h"

@implementation EKEventStore
static EKEventStore *sharedData_ = nil;

+ (EKEventStore *)sharedManager{
   @synchronized(self){
       if (!sharedData_) {
           sharedData_ = [EKEventStore new];
       }
   }
   return sharedData_;
}


- (id)init
{
   self = [super init];
   if (self) {
       //Initialization
   }
   return self;
}

//demoMethod
-(void)setSingletonArray:(NSArray *)array{
   self.singletonArray = array;
}

@end
