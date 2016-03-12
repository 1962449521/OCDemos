/*!
 @header NetAccess.h
 @abstract 网络访问常量设置
 @author 胡 帅
 @version 1.00 2014/05 Creation
 */

#define NETWORK_NeedTest YES //检验网络
#define NETWORK_TimeoutInterVal 12 //超时时间
#define NETACCESS_Success (result && [result[@"success"] boolValue])

typedef enum{
    AccessMethodGET,
    AccessMethodPOST,
    AccessMethodPUT,
    AccessMethodDELETE,
    AccessMethodHEAD
} AccessMethod;//网络访问方式
typedef enum{
    ErrorNet,//网络连接错误
    ErrorASI,// 接口服务器访问错误
    ErrorTimeOut,//请求被主动取消
    ErrorCancel//请求被主动取消
}NetAccessError;//网络访问错误

#define unQueueRequestId @-1//非队列请求时不需要标识区分不同的REQUEST