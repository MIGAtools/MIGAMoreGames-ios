/*
 *  MIGAAvailability.h
 *  MIGAUtils
 *
 *  Created by Darryl H. Thomas on 8/29/10.
 *  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
 *
 */

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30200
#define MIGA_IOS_PRE_3_2_SUPPORTED 1
#else
#define MIGA_IOS_PRE_3_2_SUPPORTED 0
#endif
#else
#define MIGA_IOS_PRE_3_2_SUPPORTED 1 // Assume yes if not explicitly determinable
#endif

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= 30200
#define MIGA_IOS_3_2_SUPPORTED __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#else
#define MIGA_IOS_3_2_SUPPORTED 0
#endif
#else
#define MIGA_IOS_3_2_SUPPORTED __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#endif

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#if __IPHONE_OS_VERSION_MIN_REQUIRED <= 40000
#define MIGA_IOS_4_0_SUPPORTED __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#else
#define MIGA_IOS_4_0_SUPPORTED 0
#endif
#else
#define MIGA_IOS_4_0_SUPPORTED __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#endif
