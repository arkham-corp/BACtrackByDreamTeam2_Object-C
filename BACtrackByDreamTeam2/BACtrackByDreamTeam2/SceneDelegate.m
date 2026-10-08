//
//  SceneDelegate.m
//  BACtrackByDreamTeam2
//
//  Created by コムエンジニアリング on 2025/09/17.
//

#import "SceneDelegate.h"
#import "MainViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {

    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

        UINavigationBar *navibar = [UINavigationBar appearance];
        navibar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        navibar.prefersLargeTitles = NO;

        // メインスレッドで実行（正しい方法）
        dispatch_async(dispatch_get_main_queue(), ^{
            MainViewController *viewController =
                [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
            self.navigationControl =
                [[UINavigationController alloc] initWithRootViewController:viewController];

            [self.navigationControl setNavigationBarHidden:NO animated:NO];
            [self.navigationControl setToolbarHidden:YES animated:NO];

            self.window.rootViewController = self.navigationControl;
            [self.window makeKeyAndVisible];
        });
    }
}
@end

