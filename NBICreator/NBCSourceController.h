//
//  NBCSourceController.h
//  NBICreator
//
//  Created by Erik Berglund on 2015-05-02.
//  Copyright (c) 2015 NBICreator. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NBCDisk;
@class NBCSource;

@interface NBCSourceController : NSObject

// ------------------------------------------------------
//  Drop Destination
// ------------------------------------------------------
- (BOOL)getInstallESDURLfromSourceURL:(NSURL *)sourceURL source:(NBCSource *)source error:(NSError **)error;

// ------------------------------------------------------
//  System
// ------------------------------------------------------
- (BOOL)verifySystemFromDisk:(NBCDisk *)systemDisk source:(NBCSource *)source error:(NSError **)error;
- (BOOL)verifySystemFromDiskImageURL:(NSURL *)systemDiskImageURL source:(NBCSource *)source error:(NSError **)error;

// ------------------------------------------------------
//  Recovery Partition
// ------------------------------------------------------
- (BOOL)verifyRecoveryPartitionFromSystemDisk:(NBCDisk *)systemDisk source:(NBCSource *)source error:(NSError **)error;
- (BOOL)verifyRecoveryPartitionFromSystemDiskImageURL:(NSURL *)systemDiskImageURL source:(NBCSource *)source error:(NSError **)error;

// ------------------------------------------------------
//  Base System
// ------------------------------------------------------
- (BOOL)verifyBaseSystemFromSource:(NBCSource *)source error:(NSError **)error;

// ------------------------------------------------------
//  InstallESD
// ------------------------------------------------------
- (BOOL)verifyInstallESDFromDiskImageURL:(NSURL *)installESDDiskImageURL source:(NBCSource *)source error:(NSError **)error;

// ------------------------------------------------------
//  Prepare Workflow
// ------------------------------------------------------
- (void)addSystemUIServer:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addSystemkeychain:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addPython:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addNTP:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addVNC:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addARD:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;
- (void)addKerberos:(NSMutableDictionary *)sourceItemsDict source:(NBCSource *)source;

@end