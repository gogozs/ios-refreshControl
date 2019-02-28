//
//  SZRefershDefines.h
//  Pods
//
//  Created by songzhou on 2018/8/12.
//

#ifndef SZRefershDefines_h
#define SZRefershDefines_h

#define SZ_LOG_ENABLE 1
#define SZ_LOG_LEVEL_VERBOSE 0

#if SZ_LOG_ENABLE == 1
#define SZLog(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#define SZLog(format, ...)
#endif

#if SZ_LOG_ENABLE == 1 && SZ_LOG_LEVEL_VERBOSE == 1
#define SZLogVerbose(format, ...) NSLog(format, ##__VA_ARGS__);
#else
#define SZLogVerbose(format, ...)
#endif

#endif /* SZRefershDefines_h */
