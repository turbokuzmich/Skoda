//#define ApiDomain @"http://ice-boroda.ru"
#define ApiDomain @"http://beard.lab.devspark.ru"

// beards fetching
#define ApiBeardManagerCheckUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/data/", nil]

// login check
#define ApiAuthLoginCheckUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/data/", nil]

// authorization
#define ApiCookieDomain ApiDomain
#define ApiAuthVkontakteLoginUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/auth/vkontakte", nil]
#define ApiAuthFacebookLoginUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/auth/facebook", nil]
#define ApiAuthOdnoklassnikiLoginUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/auth/odnoklassniki", nil]
#define ApiAuthSiteRegisterUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/auth/registration", nil]
#define ApiAuthSiteLoginUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/auth/login", nil]
#define ApiAuthLogoutUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/logout", nil]

// uploading beards
#define ApiBeardUploadUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/upload/", nil]

// photo list and view
#define ApiPhotosListUrls [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/gallery/list", nil]

// photo delete
#define ApiPhotoDeleteUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/deletephoto", nil]

// profile edit
#define ApiProfileEditUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/profile/edit", nil]

// linking photos
#define ApiPersonLikeUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/vote", nil]
#define ApiPersonVkLikeUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/vkshare", nil]
#define ApiPersonFbLikeUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/fbshare", nil]
#define ApiPersonOkLikeUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/api/okshare", nil]

// web страницы
#define PageAboutUrl [NSString stringWithFormat:@"%@%@", ApiDomain, @"/m/about", nil]
#define PageList13Url [NSString stringWithFormat:@"%@%@", ApiDomain, @"/m/gallery/top", nil]