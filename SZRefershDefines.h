//
//  SZRefershDefines.h
//  Pods
//
//  Created by songzhou on 2018/8/12.
//

#ifndef SZRefershDefines_h
#define SZRefershDefines_h

#define SZ_LOG_ENABLE 1

#ifndef SZ_LOG_ENABLE
#define SZLog(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#define SZLog(format, ...)
#endif


#endif /* SZRefershDefines_h */
