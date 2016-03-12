/*!
 @header NetAccess.h
 @abstract 网络访问框架
 @author 胡 帅
 @version 1.00 2014/05 Creation
 */




#import "AsynNetAccessQueue.h"
#import "NetAccessConst.h"
#import "ASIDownloadCache.h"
#import "NetAccessModuleDelegate.h"


@interface NetAccess : NSObject<NetAccessModuleDelegate>

@property (nonatomic, weak) id<AsynNetAccessDelegate> delegate;
/**
 *	@brief	得到系统的时间戳
 *
 *	@return
 */
- (NSNumber *)getServerTimestamp;

-(void)PrintNSData: (NSData *)data;


@end

