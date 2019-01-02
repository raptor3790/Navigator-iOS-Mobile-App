//
//  WSConstant.h
//  Turnkey
//
//  Created by C218 on 08/11/16.
//  Copyright © 2016 C218. All rights reserved.
//

#ifndef WSConstant_h
#define WSConstant_h

#define isService( key ) \
[requestURL isEqualToString: key ]

#define ENV_DEV         0
#define ENV_PROD        1


#define Server_Type ENV_PROD

#if Server_Type == ENV_DEV

#define Server_URL      @"https://rallynavigator-staging.herokuapp.com/api"
#define ServerPath      @"/v1/"
#define BUCKET_NAME     @"new-staging-rallynavigator"

#else

#define Server_URL      @"https://www.rallynavigator.com/api"
#define ServerPath      @"/v1/"
#define BUCKET_NAME     @"rallynavigator"

#endif

#define BASE_URL [NSString stringWithFormat:@"%@%@",Server_URL,ServerPath]
//#define BASE_URL [NSString stringWithFormat:@"https://www.rallynavigator.com/api%@",ServerPath]

#define ShowNetworkIndicator(XXX) [UIApplication sharedApplication].networkActivityIndicatorVisible = XXX;
#define NetworkLost @"The network connection was lost."
#define NoNetwork @"No internet connection."


//#define URLUploadImage @"https://rallynavigator.s3.amazonaws.com/"
#define URLUploadImage @"https://new-staging-rallynavigator.s3.amazonaws.com/"

#define URLLogin [NSString stringWithFormat:@"%@auth/sign_in",BASE_URL]
#define URLSignUp [NSString stringWithFormat:@"%@auth/sign_up",BASE_URL]
#define URLSocialLogin [NSString stringWithFormat:@"%@auth/sign_in_by_social_network", BASE_URL]
#define URLGetConfig [NSString stringWithFormat:@"%@auth/get_config", BASE_URL]
#define URLSetConfig [NSString stringWithFormat:@"%@auth/set_config", BASE_URL]

#define URLGetMyRoadBooks [NSString stringWithFormat:@"%@routes?page=1&per_page=1000",BASE_URL]
#define URLGetMyFolders [NSString stringWithFormat:@"%@folders",BASE_URL]
//#define URLGetMyRoadBooks [NSString stringWithFormat:@"%@routes",BASE_URL]
#define URLGetRouteDetails [NSString stringWithFormat:@"%@routes", BASE_URL]

#define URLDeleteRoadBook [NSString stringWithFormat:@"%@routes/",BASE_URL]

#define URLRegistration [NSString stringWithFormat:@"%@user/register",BASE_URL]
#define URLForgotPassword [NSString stringWithFormat:@"%@auth/forgot_password",BASE_URL]
#define URLSaveProfile [NSString stringWithFormat:@"%@user/profile/save",BASE_URL]
#define URLCheckEmail [NSString stringWithFormat:@"%@user/checkEmailExists",BASE_URL]

#define URLGetOwnProfile [NSString stringWithFormat:@"%@user/profile/get",BASE_URL]
#define URLGetOwnAlbum [NSString stringWithFormat:@"%@content/user/albums",BASE_URL]

#define URLGetFriendList [NSString stringWithFormat:@"%@user/friends/list",BASE_URL]
#define URLSearchFriend [NSString stringWithFormat:@"%@user/search",BASE_URL]

#define URLSendRequest(email_id) [NSString stringWithFormat:@"%@user/friendRequest/%@/send", BASE_URL, email_id]
#define URLAcceptRequest(email_id) [NSString stringWithFormat:@"%@user/friendRequest/%@/accept", BASE_URL, email_id]
#define URLRejectRequest(email_id) [NSString stringWithFormat:@"%@user/friendRequest/%@/reject", BASE_URL, email_id]
#define URLCancelRequest(email_id) [NSString stringWithFormat:@"%@user/friendRequest/%@/cancel", BASE_URL, email_id]

#define URLReceivedFriendRequests [NSString stringWithFormat:@"%@user/friends/req/received", BASE_URL]
#define URLSentFriendRequests [NSString stringWithFormat:@"%@user/friends/req/sent", BASE_URL]

#define URLLogOut [NSString stringWithFormat:@"%@user/logout",BASE_URL]

#pragma mark - Class,Json Key and Message

#define LoginClass @"User"
#define LoginEntity @""
#define LoginKey @"user"
#define LoginMsg @"Processing"

#define RoadbooksClass @"Roadbooks"
#define RoadbooksEntity @"CDRoadbooks"
#define RoadbooksKey @"Roadbooks"
#define RoadbooksMsg @"Processing"

#define RoadBooksClass @"Routes"
#define RoadBooksEntity @"CDRoutes"
#define RoadBooksKey @"routes"
#define RoadBooksMsg @"Processing"

#define RouteClass @"Route"
#define RouteEntity @"CDRoute"
#define RouteKey @"route"
#define RouteMsg @"Processing"


#define SUCCESS_STATUS      @"success"
#define FAILED_STATUS       @"failed"
#define ERROR_CODE       @"error_code"
#define ERROR_STATUS       @"error"
#define MESSAGE             @"message"
#define STATUS              @"status"
#define WSAuthKey                  @"auth"
#define WSClassKey                  @"data"
#define WSErrorMsg                  @"Unable to get response"
//====================================

#define UsersDetailClass         @"users"
#define ClassCoreDataUser       @"CoreDataUser"



#endif /* WSConstant_h */
