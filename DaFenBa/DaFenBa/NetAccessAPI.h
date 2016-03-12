//
//  NetAccessAPI.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-28.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

//服务器地址
#define HOST @"http://www.rateme8.com/"
//#define HOST @"http://www.hzjhp.com:8080/"

// UtiModule
#define UtiModule_time HOST@"util/time"

// UserModule     1
#define USERMODULE HOST@"user/"
#define UserModule_register USERMODULE@"register"
#define UserModule_register_method AccessMethodPOST
#define UserModule_register_tag @11

#define UserModule_login    USERMODULE@"login"
#define UserModule_login_method AccessMethodPOST
#define UserModule_login_tag @12

#define UserModule_update   USERMODULE@"update"
#define UserModule_update_method AccessMethodPUT
#define UserModule_update_tag @13

#define UserModule_detail   USERMODULE@"detail"
#define UserModule_detail_method AccessMethodPOST
#define UserModule_detail_tag @14


#define UserModule_resetPwd USERMODULE@"resetPwd"
#define UserModule_resetPwd_method AccessMethodPUT
#define UserModule_resetPwd_tag @15

#define UserModule_updateMobile USERMODULE@"updateMobile"
#define UserModule_updateMobile_method AccessMethodPUT
#define UserModule_updateMobile_tag @16

#define UserModule_loadMobile   USERMODULE@"loadMobile"
#define UserModule_loadMobile_method AccessMethodPOST
#define UserModule_loadMobile_tag @17



// FriendModule   2
#define FRIENDMODULE HOST@"friend/"

#define FriendModule_follow       FRIENDMODULE@"follow"
#define FriendModule_follow_method AccessMethodPOST
#define FriendModule_follow_tag @21

#define FriendModule_deleteFollow FRIENDMODULE@"deleteFollow"
#define FriendModule_deleteFollow_method AccessMethodDELETE
#define FriendModule_deleteFollow_tag  @22

#define FriendModule_count        FRIENDMODULE@"count"
#define FriendModule_count_method AccessMethodPOST
#define FriendModule_count_tag  @23

#define FriendModule_list         FRIENDMODULE@"list"
#define FriendModule_list_method AccessMethodPOST
#define FriendModule_list_tag  @24

#define FriendModule_isFollow     FRIENDMODULE@"isFollow"
#define FriendModule_isFollow_method AccessMethodPOST
#define FriendModule_isFollow_tag  @25


//#define FriendModule_listFollow   FRIENDMODULE@"friend/listFollow"
//#define FriendModule_listFollow_method AccessMethodPOST
//#define FriendModule_listFollow_tag  @24
//
//#define FriendModule_listFollower FRIENDMODULE@"friend/listFollow"
//#define FriendModule_listFollower_method AccessMethodPOST
//#define FriendModule_listFollower_tag  @24


// SnsModule      3
#define SNSMODULE HOST@"sns/"

#define SnsModule_login  SNSMODULE@"login"
#define SnsModule_login_method AccessMethodPOST
#define SnsModule_login_tag @31

#define SnsModule_share  SNSMODULE@"share"
#define SnsModule_share_method AccessMethodPOST
#define SnsModule_share_tag @32



// SmsModule      4
#define SMSMODULE HOST@"sms/"

#define SmsModule_captcha SMSMODULE@"captcha"
#define SmsModule_captcha_method AccessMethodPOST
#define SmsModule_captcha_tag @41


// PostModule     5
#define POSTMODULE HOST@"post/"

#define PostModule_count  POSTMODULE@"count"
#define PostModule_count_method AccessMethodPOST
#define PostModule_count_tag @51

#define PostModule_list   POSTMODULE@"list"
#define PostModule_list_method AccessMethodPOST
#define PostModule_list_tag @52

#define PostModule_myPostList   POSTMODULE@"myPostList"
#define PostModule_myPostList_method AccessMethodPOST
#define PostModule_myPostList_tag @57

#define PostModule_detail POSTMODULE@"detail"
#define PostModule_detail_method AccessMethodPOST
#define PostModule_detail_tag @53

#define PostModule_add    POSTMODULE@"add"
#define PostModule_add_method AccessMethodPOST
#define PostModule_add_tag @54

#define PostModule_update POSTMODULE@"update"
#define PostModule_update_method AccessMethodPUT
#define PostModule_update_tag @55

#define PostModule_delete POSTMODULE@"delete"
#define PostModule_delete_method AccessMethodDELETE
#define PostModule_delete_tag @56

// GradeModule    6
#define GRADEMODULE HOST@"grade/"

#define GradeModule_add      GRADEMODULE@"add"
#define GradeModule_add_method AccessMethodPOST
#define GradeModule_add_tag @61

#define GradeModule_update   GRADEMODULE@"update"
#define GradeModule_update_method AccessMethodPUT
#define GradeModule_update_tag @62

#define GradeModule_delete   GRADEMODULE@"delete"
#define GradeModule_delete_method AccessMethodDELETE
#define GradeModule_delete_tag @63 

#define GradeModule_list     GRADEMODULE@"list"
#define GradeModule_list_method AccessMethodPOST
#define GradeModule_list_tag @64

#define GradeModule_listForPost     GRADEMODULE@"listForPost"
#define GradeModule_listForPost_method AccessMethodPOST
#define GradeModule_listForPost_tag @65

#define GradeModule_listForMine     GRADEMODULE@"listForMine"
#define GradeModule_listForMine_method AccessMethodPOST
#define GradeModule_listForMine_tag @66



#define GradeModule_invite   GRADEMODULE@"invite"
#define GradeModule_invite_method AccessMethodPOST
#define GradeModule_invite_tag @67


#define GradeModule_post HOST@"GradeModule/post"
#define GradeModule_post_tag @65


// AdviceModule   7
#define ADVICEMODULE HOST@"advice/"

#define AdviceModule_add      ADVICEMODULE@"add"
#define AdviceModule_add_method AccessMethodPOST
#define AdviceModule_add_tag @71

#define AdviceModule_update   ADVICEMODULE@"update"
#define AdviceModule_update_method AccessMethodPUT
#define AdviceModule_update_tag @72

#define AdviceModule_delete   ADVICEMODULE@"delete"
#define AdviceModule_delete_method AccessMethodDELETE
#define AdviceModule_delete_tag @73

#define AdviceModule_detail     ADVICEMODULE@"detail"
#define AdviceModule_detail_method AccessMethodPOST
#define AdviceModule_detail_tag @74

#define AdviceModule_list     ADVICEMODULE@"list"
#define AdviceModule_list_method AccessMethodPOST
#define AdviceModule_list_tag @75

#define AdviceModule_invite   ADVICEMODULE@"invite"
#define AdviceModule_invite_method AccessMethodPOST
#define AdviceModule_invite_tag @76

// ReplyModule    8
#define REPLYMODULE HOST@"reply/"

#define ReplyModule_add               REPLYMODULE@"add"
#define ReplyModule_add_method AccessMethodPOST
#define ReplyModule_add_tag @81

#define ReplyModule_delete            REPLYMODULE@"delete"
#define ReplyModule_delete_method AccessMethodDELETE
#define ReplyModule_delete_tag @82

#define ReplyModule_list              REPLYMODULE@"list"
#define ReplyModule_list_method AccessMethodPOST
#define ReplyModule_list_tag @83

#define ReplyModule_advice_reply_list REPLYMODULE@"advice_reply_list"
#define ReplyModule_advice_reply_list_method AccessMethodPOST
#define ReplyModule_advice_reply_list_tag @84

#define ReplyModule_grade_reply_list REPLYMODULE@"grade_reply_list"
#define ReplyModule_grade_reply_list_method AccessMethodPOST
#define ReplyModule_grade_reply_list_tag @85


// FeedbackModule  9
#define FEEDBACKMODULE HOST@"feedback/"

#define FeedbackModule_add  FEEDBACKMODULE@"add"
#define FeedbackModule_add_method AccessMethodPOST
#define FeedbackModule_add_tag @91

// MessageModule   10
#define MESSAGEMODULE HOST@"message/"

#define MessageModule_add      MESSAGEMODULE@"add"
#define MessageModule_add_method AccessMethodPOST
#define MessageModule_add_tag @101

#define MessageModule_delete   MESSAGEMODULE@"remove"
#define MessageModule_delete_method AccessMethodDELETE
#define MessageModule_delete_tag @102

#define MessageModule_list     MESSAGEMODULE@"list"
#define MessageModule_list_method AccessMethodPOST
#define MessageModulee_list_tag @103
// DiscoverModule  11
#define DISCOVERMODULE HOST@"discovery/"

#define DiscoverModule_list  DISCOVERMODULE@"add"
#define DiscoverModule_list_method AccessMethodPOST
#define DiscoverModule_list_tag @111
// PushModule      12
#define PUSHMODULE HOST@"push/"

#define PushModule_add PUSHMODULE@"add"
#define PushModule_add_method AccessMethodPOST
#define PushModule_add_tag @121
// UserHonorModule 13
#define USERHONORMODULE HOST@"userHonor/"

#define UserHonorModule_list USERHONORMODULE@"load"
#define UserHonorModule_list_method AccessMethodPOST
#define UserHonorModule_list_tag @131

// MedalModule     14
#define MEDALMODULE HOST@"medal/"

#define MedalModule_list MEDALMODULE@"list"
#define MedalModule_list_method AccessMethodPOST
#define MedalModule_list_tag @141
// DecibelModule   15
#define DECIBELMODULE HOST@"decibel/"

#define DecibelModule_list DECIBELMODULE@"list"
#define DecibelModule_list_method AccessMethodPOST
#define DecibelModule_list_tag @151
// OptionModule    16
#define OPTIONMODULE HOST@"option/"

#define OptionModule_list OPTIONMODULE@"load"
#define OptionModule_list_method AccessMethodPOST
#define OptionModule_list_tag @161

#define OptionModule_update   OPTIONMODULE@"update"
#define OptionModule_update_method AccessMethodPUT
#define OptionModule_update_tag @162
// NotificationModule 17
#define NOTIFICATIONMODULE HOST@"notification/"

#define NotificationModule_list NOTIFICATIONMODULE@"list"
#define NotificationModule_list_method AccessMethodPOST
#define NotificationModule_list_tag @171

#define NotificationModule_listFromMe NOTIFICATIONMODULE@"listFromMe"
#define NotificationModule_listFromMe_method AccessMethodPOST
#define NotificationModule_listFromMe_tag @172

#define NotificationModule_listFromHis NOTIFICATIONMODULE@"listFromHis"
#define NotificationModule_listFromMe_method AccessMethodPOST
#define NotificationModule_listFromMe_tag @173





//自有服务器注册登录
#define RegisterURL HOST@"UserModule/register"
#define RegisterURL_tag @1
#define LoginURL HOST@"UserModule/login"
#define LoginURL_tag @2



