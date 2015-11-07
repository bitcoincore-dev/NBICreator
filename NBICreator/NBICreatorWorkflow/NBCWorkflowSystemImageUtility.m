//
//  NBCWorkflowSystemImageUtility.m
//  NBICreator
//
//  Created by Erik Berglund on 2015-11-06.
//  Copyright © 2015 NBICreator. All rights reserved.
//

#import "NBCWorkflowSystemImageUtility.h"
#import "NBCWorkflowItem.h"

#import "NBCError.h"
#import "NBCConstants.h"
#import "NBCLogging.h"

#import "NBCHelperProtocol.h"
#import "NBCHelperConnection.h"
#import "NBCWorkflowNBIController.h"

@implementation NBCWorkflowSystemImageUtility

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithDelegate:(id<NBCWorkflowProgressDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create NBI
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)createNBI:(NBCWorkflowItem *)workflowItem {
    
    NSError *error = nil;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [self setWorkflowItem:workflowItem];
    [self setPackageOnly:[[workflowItem userSettings][NBCSettingsNetInstallPackageOnlyKey] boolValue]];
    [self setNbiVolumeName:[[workflowItem nbiName] stringByDeletingPathExtension]];
    
    // ------------------------------------------------------------------
    //  Check and set temporary NBI URL to property
    // ------------------------------------------------------------------
    NSURL *temporaryNBIURL = [workflowItem temporaryNBIURL];
    DDLogDebug(@"[DEBUG] Temporary nbi path: %@", [temporaryNBIURL path]);
    
    if ( [temporaryNBIURL checkResourceIsReachableAndReturnError:&error] ) {
        [self setTemporaryNBIURL:temporaryNBIURL];
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Temporary NBI path not found"] }];
        return;
    }
    
    // -------------------------------------------------------------
    //  Copy required items to NBI folder
    // -------------------------------------------------------------
    if ( ! [self prepareWorkflowFolder:_temporaryNBIURL error:&error] ) {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Preparing workflow folder failed"] }];
        return;
    }
    
    // ---------------------------------------------------------
    //  Prepare script and variables for selected workflow type
    // ---------------------------------------------------------
    if ( _packageOnly ) {
        [self prepareWorkflowPackageOnly];
    } else {
        [self prepareWorkflowNetInstall];
    }
}

- (BOOL)prepareWorkflowFolder:(NSURL *)workflowFolderURL error:(NSError **)error {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // -------------------------------------------------------------------
    //  Create array for temporary items to be deleted at end of workflow
    // -------------------------------------------------------------------
    NSMutableArray *temporaryItemsNBI = [[_workflowItem temporaryItemsNBI] mutableCopy] ?: [[NSMutableArray alloc] init];
    
    // -------------------------------------------------
    //  Set temporary NBI NetInstall.dmg path to target
    // -------------------------------------------------
    NSURL *nbiNetInstallTemporaryURL = [workflowFolderURL URLByAppendingPathComponent:@"NetInstall.dmg"];
    DDLogDebug(@"[DEBUG] NBI NetInstall disk image temporary path: %@", [nbiNetInstallTemporaryURL path]);
    [[_workflowItem target] setNbiNetInstallURL:nbiNetInstallTemporaryURL];
    
    // ------------------------------------
    //  Copy createCommon.sh to NBI folder
    // ------------------------------------
    NSURL *createCommonURL = [[_workflowItem applicationSource] createCommonURL];
    DDLogDebug(@"[DEBUG] createCommon.sh path: %@", [createCommonURL path]);
    
    NSURL *createCommonTargetURL = [workflowFolderURL URLByAppendingPathComponent:[createCommonURL lastPathComponent]];
    DDLogDebug(@"[DEBUG] createCommon.sh target path: %@", [createCommonTargetURL path]);
    
    if ( [fm copyItemAtURL:createCommonURL toURL:createCommonTargetURL error:error] ) {
        [temporaryItemsNBI addObject:createCommonTargetURL];
    } else {
        return NO;
    }
    
    // ----------------------------------------------------------------
    //  If this is a NetInstall workflow, check any additional content
    // ----------------------------------------------------------------
    if ( [_workflowItem workflowType] == kWorkflowTypeNetInstall ) {
        
        NSDictionary *resourcesSettings = [_workflowItem resourcesSettings];
        
        BOOL writeOSInstall = NO;
        NSMutableArray *osInstallArray = [NSMutableArray arrayWithArray:@[ @"/System/Installation/Packages/OSInstall.mpkg",
                                                                           @"/System/Installation/Packages/OSInstall.mpkg" ]];
        
        // -------------------------------------------
        //  Prepare to install configuration profiles
        // -------------------------------------------
        NSArray *configurationProfilesNetInstall = resourcesSettings[NBCSettingsConfigurationProfilesNetInstallKey];
        if ( [configurationProfilesNetInstall count] != 0 ) {
            
            // -------------------------------------------
            //  configProfiles.txt
            // -------------------------------------------
            NSURL *configProfilesURL = [_temporaryNBIURL URLByAppendingPathComponent:@"configProfiles.txt"];
            DDLogDebug(@"[DEBUG] configProfiles.txt path: %@", [configProfilesURL path]);
            
            [temporaryItemsNBI addObject:configProfilesURL];
            
            NSMutableString *configProfilesContent = [[NSMutableString alloc] init];
            for ( NSString *configProfilePath in configurationProfilesNetInstall ) {
                [configProfilesContent appendString:[NSString stringWithFormat:@"%@\n", configProfilePath]];
            }
            
            if ( [configProfilesContent writeToURL:configProfilesURL atomically:YES encoding:NSUTF8StringEncoding error:error] ) {
                writeOSInstall = YES;
            } else {
                return NO;
            }
            
            // -------------------------------------------
            //  installConfigurationProfiles.sh
            // -------------------------------------------
            NSURL *installConfigurationProfilesScriptURL = [[_workflowItem applicationSource] installConfigurationProfiles];
            DDLogDebug(@"[DEBUG] installConfigurationProfiles.sh path: %@", [installConfigurationProfilesScriptURL path]);
            
            NSURL *installConfigurationProfilesScriptTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[installConfigurationProfilesScriptURL lastPathComponent]];
            DDLogDebug(@"[DEBUG] installConfigurationProfiles.sh target path: %@", [installConfigurationProfilesScriptTargetURL path]);
            
            [temporaryItemsNBI addObject:installConfigurationProfilesScriptTargetURL];
            
            if ( [[NSFileManager defaultManager] copyItemAtURL:installConfigurationProfilesScriptURL toURL:installConfigurationProfilesScriptTargetURL error:error] ) {
                [osInstallArray addObject:[NSString stringWithFormat:@"/System/Installation/Packages/%@.pkg", [installConfigurationProfilesScriptURL lastPathComponent]]];
            } else {
                return NO;
            }
        }
        
        // -------------------------------------------
        //  Prepare trusted netboot servers
        // -------------------------------------------
        NSArray *trustedNetBootServers = resourcesSettings[NBCSettingsTrustedNetBootServersKey];
        if ( [trustedNetBootServers count] != 0 ) {
            
            // -------------------------------------------
            //  bsdpSources.txt
            // -------------------------------------------
            NSURL *bsdpSourcesURL = [_temporaryNBIURL URLByAppendingPathComponent:@"bsdpSources.txt"];
            DDLogDebug(@"[DEBUG] bsdpSources.txt path: %@", [bsdpSourcesURL path]);
            
            [temporaryItemsNBI addObject:bsdpSourcesURL];
            
            NSMutableString *bsdpSourcesContent = [[NSMutableString alloc] init];
            for ( NSString *netBootServerIP in trustedNetBootServers ) {
                [bsdpSourcesContent appendString:[NSString stringWithFormat:@"%@\n", netBootServerIP]];
            }
            
            if ( [bsdpSourcesContent writeToURL:bsdpSourcesURL atomically:YES encoding:NSUTF8StringEncoding error:error] ) {
                writeOSInstall = YES;
            } else {
                return NO;
            }
            
            // -------------------------------------------
            //  addBSDPSources.sh
            // -------------------------------------------
            NSURL *addBSDPSourcesScriptURL = [[_workflowItem applicationSource] addBSDPSourcesURL];
            DDLogDebug(@"[DEBUG] addBSDPSources.sh path: %@", [addBSDPSourcesScriptURL path]);
            
            if ( _packageOnly ) {
                NSURL *addBSDPSourcesScriptTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[addBSDPSourcesScriptURL lastPathComponent]];
                DDLogDebug(@"[DEBUG] addBSDPSources.sh target path: %@", [addBSDPSourcesScriptTargetURL path]);
                
                if ( ! [[NSFileManager defaultManager] copyItemAtURL:addBSDPSourcesScriptURL toURL:addBSDPSourcesScriptTargetURL error:error] ) {
                    return NO;
                }
            } else {
                NSURL *additionalScriptsURL = [_temporaryNBIURL URLByAppendingPathComponent:@"additionalScripts.txt"];
                DDLogDebug(@"[DEBUG] additionalScripts.txt path: %@", [additionalScriptsURL path]);
                
                NSMutableString *additionalScriptsContent = [[NSMutableString alloc] initWithContentsOfURL:additionalScriptsURL encoding:NSUTF8StringEncoding error:error] ?: [[NSMutableString alloc] init];
                
                [additionalScriptsContent appendString:[NSString stringWithFormat:@"%@\n", [addBSDPSourcesScriptURL path]]];
                [osInstallArray addObject:[NSString stringWithFormat:@"/System/Installation/Packages/%@.pkg", [addBSDPSourcesScriptURL lastPathComponent]]];
                
                if ( [additionalScriptsContent writeToURL:additionalScriptsURL atomically:YES encoding:NSUTF8StringEncoding error:error] ) {
                    writeOSInstall = YES;
                } else {
                    return NO;
                }
            }
        }
        
        // -------------------------------------------
        //  Prepare packages and scripts
        // -------------------------------------------
        NSArray *packagesNetInstall = resourcesSettings[NBCSettingsNetInstallPackagesKey];
        if ( [packagesNetInstall count] != 0 ) {
            
            // -------------------------------------------
            //  additionalPackages.txt
            // -------------------------------------------
            NSURL *additionalPackagesURL = [_temporaryNBIURL URLByAppendingPathComponent:@"additionalPackages.txt"];
            DDLogDebug(@"[DEBUG] additionalPackages.txt path: %@", [additionalPackagesURL path]);
            
            [temporaryItemsNBI addObject:additionalPackagesURL];
            NSMutableString *additionalPackagesContent = [[NSMutableString alloc] init];
            
            // -------------------------------------------
            //  additionalScripts.txt
            // -------------------------------------------
            NSURL *additionalScriptsURL = [_temporaryNBIURL URLByAppendingPathComponent:@"additionalScripts.txt"];
            DDLogDebug(@"[DEBUG] additionalScripts.txt path: %@", [additionalScriptsURL path]);
            
            NSMutableString *additionalScriptsContent = [[NSMutableString alloc] initWithContentsOfURL:additionalScriptsURL encoding:NSUTF8StringEncoding error:error] ?: [[NSMutableString alloc] init];
            
            NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
            for ( NSString *packagePath in packagesNetInstall ) {
                NSString *fileType = [[NSWorkspace sharedWorkspace] typeOfFile:packagePath error:error];
                if ( [workspace type:fileType conformsToType:@"com.apple.installer-package-archive"] ) {
                    [additionalPackagesContent appendString:[NSString stringWithFormat:@"%@\n", packagePath]];
                    [osInstallArray addObject:[NSString stringWithFormat:@"/System/Installation/Packages/%@", [packagePath lastPathComponent]]];
                } else if ( [workspace type:fileType conformsToType:@"public.shell-script"] ) {
                    [additionalScriptsContent appendString:[NSString stringWithFormat:@"%@\n", packagePath]];
                    [osInstallArray addObject:[NSString stringWithFormat:@"/System/Installation/Packages/%@.pkg", [packagePath lastPathComponent]]];
                }
            }
            [additionalPackagesContent appendString:@"\\n"];
            
            [temporaryItemsNBI addObject:additionalScriptsURL];
            if ( [configurationProfilesNetInstall count] != 0 ) {
                NSURL *netInstallConfigurationProfilesScriptURL = [[_workflowItem applicationSource] netInstallConfigurationProfiles];
                DDLogDebug(@"[DEBUG] netInstallConfigurationProfiles.sh path: %@", [netInstallConfigurationProfilesScriptURL path]);
                
                [additionalScriptsContent appendString:[NSString stringWithFormat:@"%@\n", [netInstallConfigurationProfilesScriptURL path]]];
            }
            
            if ( [additionalPackagesContent writeToURL:additionalPackagesURL atomically:YES encoding:NSUTF8StringEncoding error:error] ) {
                writeOSInstall = YES;
            } else {
                return NO;
            }
            
            if ( [additionalScriptsContent writeToURL:additionalScriptsURL atomically:YES encoding:NSUTF8StringEncoding error:error] ) {
                writeOSInstall = YES;
            } else {
                return NO;
            }
            
            if ( _packageOnly ) {
                if ( ! [@{} writeToURL:[_temporaryNBIURL URLByAppendingPathComponent:@"ASRInstall.mpkg"] atomically:YES] ) {
                    *error = [NBCError errorWithDescription:@"Writing ASRInstall.mpkg failed"];
                    return NO;
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        //  If any additional content was added to NetInstall, write OSInstall.collection
        // -------------------------------------------------------------------------------
        if ( writeOSInstall ) {
            NSURL *osInstallURL = [_temporaryNBIURL URLByAppendingPathComponent:@"OSInstall.collection"];
            [temporaryItemsNBI addObject:osInstallURL];
            NSDictionary *osInstallDict = (NSDictionary*)osInstallArray;
            [osInstallDict writeToURL:osInstallURL atomically:YES];
        }
    }
    
    [_workflowItem setTemporaryItemsNBI:temporaryItemsNBI];
    
    return YES;
} // prepareDestinationFolder:createCommonURL:workflowItem:error

- (void)prepareWorkflowPackageOnly {
    
    NSError *error;
    NSArray *arguments;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [self setPackageOnlyScriptRun:NO];
    
    // --------------------------------------------------------
    //  Create arguments array for createRestoreFromSources.sh
    // --------------------------------------------------------
    NSArray *createRestoreFromSourcesArguments = [NBCWorkflowNBIController generateScriptArgumentsForCreateRestoreFromSources:_workflowItem];
    if ( [createRestoreFromSourcesArguments count] != 0 ) {
        [_workflowItem setScriptArguments:createRestoreFromSourcesArguments];
        arguments = createRestoreFromSourcesArguments;
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : [NBCError errorWithDescription:@"Creating script arguments for createRestoreFromSources.sh failed"] }];
        return;
    }
    
    // --------------------------------------------------------------
    //  Create environment variables for createRestoreFromSources.sh
    // --------------------------------------------------------------
    if ( ! [NBCWorkflowNBIController generateEnvironmentVariablesForCreateRestoreFromSources:_workflowItem] ) {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : [NBCError errorWithDescription:@"Creating environment variables for createRestoreFromSources.sh failed"] }];
        return;
    }
    
    // --------------------------------
    //  Write InstallPreferences.plist
    // --------------------------------
    NSURL *installPreferencesPlistURL = [_temporaryNBIURL URLByAppendingPathComponent:@"InstallPreferences.plist"];
    DDLogDebug(@"[DEBUG] InstallPreferences.plist path: %@", [installPreferencesPlistURL path]);
    
    if ( ! [@{ @"packageOnlyMode" : @YES } writeToURL:installPreferencesPlistURL atomically:NO] ) {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : [NBCError errorWithDescription:@"Writing InstallPreferences.plist failed"] }];
        return;
    }
    
    // --------------------------------
    //  Copy ASRInstall.pkg
    // --------------------------------
    NSURL *asrInstallPkgSourceURL = [[_workflowItem applicationSource] asrInstallPkgURL];
    DDLogDebug(@"[DEBUG] ASRInstall.pkg path: %@", [asrInstallPkgSourceURL path]);
    
    if ( [asrInstallPkgSourceURL checkResourceIsReachableAndReturnError:&error] ) {
        NSURL *asrInstallPkgTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[asrInstallPkgSourceURL lastPathComponent]];
        if ( ! [fm copyItemAtURL:asrInstallPkgSourceURL toURL:asrInstallPkgTargetURL error:&error] ) {
            [nc postNotificationName:NBCNotificationWorkflowFailed
                              object:self
                            userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Copying ASRInstall.pkg failed"] }];
            return;
        }
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"ASRInstall.pkg doesn't exist"] }];
        return;
    }
    
    // --------------------------------
    //  Copy postInstallPackages.sh
    // --------------------------------
    NSURL *asrPostInstallPackagesURL = [[_workflowItem applicationSource] postInstallPackages];
    DDLogDebug(@"[DEBUG] postInstallPackages.sh path: %@", [asrPostInstallPackagesURL path]);
    
    if ( [asrPostInstallPackagesURL checkResourceIsReachableAndReturnError:&error] ) {
        NSURL *asrPostInstallPackagesTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[asrPostInstallPackagesURL lastPathComponent]];
        if ( ! [fm copyItemAtURL:asrPostInstallPackagesURL toURL:asrPostInstallPackagesTargetURL error:&error] ) {
            [nc postNotificationName:NBCNotificationWorkflowFailed
                              object:self
                            userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Copying postInstallPackages.sh failed"] }];
            return;
        }
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"postInstallPackages.sh doesn't exist"] }];
        return;
    }
    
    // --------------------------------
    //  Copy reserveInstallLog.sh
    // --------------------------------
    NSURL *preserveInstallLogURL = [[_workflowItem applicationSource] preserveInstallLog];
    DDLogDebug(@"[DEBUG] reserveInstallLog.sh path: %@", [preserveInstallLogURL path]);
    
    if ( [preserveInstallLogURL checkResourceIsReachableAndReturnError:&error] ) {
        NSURL *preserveInstallLogTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[preserveInstallLogURL lastPathComponent]];
        if ( ! [fm copyItemAtURL:preserveInstallLogURL toURL:preserveInstallLogTargetURL error:&error] ) {
            [nc postNotificationName:NBCNotificationWorkflowFailed
                              object:self
                            userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Copying reserveInstallLog.sh failed"] }];
            return;
        }
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"reserveInstallLog.sh doesn't exist"] }];
        return;
    }
    
    // --------------------------------
    //  Copy NetBootClientHelper
    // --------------------------------
    NSURL *netBootClientHelperURL = [[_workflowItem applicationSource] netBootClientHelper];
    DDLogDebug(@"[DEBUG] NetBootClientHelper path: %@", [netBootClientHelperURL path]);
    
    if ( [netBootClientHelperURL checkResourceIsReachableAndReturnError:&error] ) {
        NSURL *netBootClientHelperTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:[netBootClientHelperURL lastPathComponent]];
        if ( ! [fm copyItemAtURL:netBootClientHelperURL toURL:netBootClientHelperTargetURL error:&error] ) {
            [nc postNotificationName:NBCNotificationWorkflowFailed
                              object:self
                            userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Copying NetBootClientHelper failed"] }];
            return;
        }
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"NetBootClientHelper doesn't exist"] }];
        return;
    }
    
    // --------------------------------
    //  Create buildCommands.sh
    // --------------------------------
    NSURL *buildCommandsTargetURL = [_temporaryNBIURL URLByAppendingPathComponent:@"buildCommands.sh"];
    DDLogDebug(@"[DEBUG] buildCommands.sh path: %@", [buildCommandsTargetURL path]);
    
    NSString *buildCommandsContent = [NSString stringWithFormat:@"'%@' \"%@\" \"/\" \"System\" || exit 1\n", [[[_workflowItem applicationSource] asrFromVolumeURL] path], [_temporaryNBIURL path]];
    if ( ! [buildCommandsContent writeToURL:buildCommandsTargetURL atomically:YES encoding:NSUTF8StringEncoding error:&error] ) {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"NetBootClientHelper doesn't exist"] }];
        return;
    }
    
    // --------------------------------
    //  Create NBI
    // --------------------------------
    [self runWorkflowScriptWithArguments:arguments];
}

- (void)prepareWorkflowNetInstall {
    
    NSError *error;
    NSArray *arguments;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // ------------------------------------------------------------------
    //  Check and set InstallESD disk image volume size for progress bar
    // ------------------------------------------------------------------
    DDLogInfo(@"Getting size of InstallESD disk image volume...");
    
    NSURL *installESDVolumeURL = [[_workflowItem source] installESDVolumeURL];
    DDLogDebug(@"[DEBUG] InstallESD disk image volume path: %@", [installESDVolumeURL path]);
    
    if ( [installESDVolumeURL checkResourceIsReachableAndReturnError:&error] ) {
        NSDictionary *volumeAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[installESDVolumeURL path] error:&error];
        if ( [volumeAttributes count] != 0 ) {
            double maxSize = [volumeAttributes[NSFileSystemSize] doubleValue];
            DDLogDebug(@"[DEBUG] InstallESD disk image volume size: %f", maxSize);
            
            double freeSize = [volumeAttributes[NSFileSystemFreeSize] doubleValue];
            DDLogDebug(@"[DEBUG] InstallESD disk image volume free size: %f", freeSize);
            
            [self setNetInstallVolumeSize:( maxSize - freeSize )];
            DDLogDebug(@"[DEBUG] InstallESD disk image volume used size: %f", ( maxSize - freeSize ));
        } else {
            DDLogWarn(@"[WARN] %@", [error localizedDescription]);
        }
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"InstallESD disk image is not mounted"] }];
        return;
    }
    
    // -------------------------------------------------------------
    //  Create arguments array for createNetInstall.sh
    // -------------------------------------------------------------
    NSArray *createNetInstallArguments = [NBCWorkflowNBIController generateScriptArgumentsForCreateNetInstall:_workflowItem];
    if ( [createNetInstallArguments count] != 0 ) {
        [_workflowItem setScriptArguments:createNetInstallArguments];
        arguments = createNetInstallArguments;
    } else {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Creating script arguments for createNetInstall.sh failed"] }];
        return;
    }
    
    // -------------------------------------------------------------
    //  Create environment variables for createNetInstall.sh
    // -------------------------------------------------------------
    if ( ! [NBCWorkflowNBIController generateEnvironmentVariablesForCreateNetInstall:_workflowItem] ) {
        [nc postNotificationName:NBCNotificationWorkflowFailed
                          object:self
                        userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Creating environment variables for createNetInstall.sh failed"] }];
        return;
    }
    
    // --------------------------------
    //  Create NBI
    // --------------------------------
    [self runWorkflowScriptWithArguments:arguments];
}

- (void)runWorkflowScriptWithArguments:(NSArray *)arguments {
    
    NBCHelperConnection *helperConnector = [[NBCHelperConnection alloc] init];
    [helperConnector connectToHelper];
    [[helperConnector connection] setExportedObject:self];
    [[helperConnector connection] setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(NBCWorkflowProgressDelegate)]];
    [[[helperConnector connection] remoteObjectProxyWithErrorHandler:^(NSError * proxyError) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NBCNotificationWorkflowFailed
                                                                object:self
                                                              userInfo:@{ NBCUserInfoNSErrorKey : proxyError ?: [NBCError errorWithDescription:@"Creating NBI failed"] }];
        }];
    }] runTaskWithCommand:@"/bin/sh" arguments:arguments currentDirectory:nil environmentVariables:@{} withReply:^(NSError *error, int terminationStatus) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if ( terminationStatus == 0 ) {
                [self finalizeNBI];
            } else {
                if ( self->_packageOnly && ! self->_packageOnlyScriptRun ) {
                    DDLogDebug(@"[DEBUG] createRestoreFromSources.sh failed on first try, trying again...");
                    [self setPackageOnlyScriptRun:YES];
                    [self runWorkflowScriptWithArguments:arguments];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NBCNotificationWorkflowFailed
                                                                        object:self
                                                                      userInfo:@{ NBCUserInfoNSErrorKey : error ?: [NBCError errorWithDescription:@"Creating NBI failed"] }];
                }
            }
        }];
    }];
}

- (void)finalizeNBI {
    
    DDLogInfo(@"Removing temporary items...");
    
    __block NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // -------------------------------------------------------------
    //  Delete all items in temporaryItems array at end of workflow
    // -------------------------------------------------------------
    NSArray *temporaryItemsNBI = [_workflowItem temporaryItemsNBI];
    for ( NSURL *temporaryItemURL in temporaryItemsNBI ) {
        DDLogDebug(@"[DEBUG] Removing item at path: %@", [temporaryItemURL path]);
        
        if ( ! [fm removeItemAtURL:temporaryItemURL error:&error] ) {
            DDLogError(@"[ERROR] %@", [error localizedDescription]);
        }
    }
    
    // -------------------------------------------------------------
    //  Delete all items in NBI root except 'allowedItems'
    // -------------------------------------------------------------
    NSArray *allowedItems = @[ @"i386", @"NetInstall.dmg", @"NBImageInfo.plist" ];
    NSArray *nbiFolderContents = [fm contentsOfDirectoryAtURL:_temporaryNBIURL includingPropertiesForKeys:@[] options:0 error:&error];
    
    [nbiFolderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        NSString *filename = [obj lastPathComponent];
        if ( ! [allowedItems containsObject:filename] ) {
            DDLogDebug(@"[DEBUG] Removing item at path: %@", [obj path]);
            
            if ( ! [fm removeItemAtURL:obj error:&error] ) {
                DDLogError(@"[ERROR] %@", [error localizedDescription]);
            }
        }
    }];
    
    // ------------------------
    //  Send workflow complete
    // ------------------------
    [[NSNotificationCenter defaultCenter] postNotificationName:NBCNotificationWorkflowCompleteNBI object:self userInfo:nil];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Progress Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)logStdOut:(NSString *)stdOutString {
    [self updateNetInstallWorkflowStatus:stdOutString];
}

- (void)updateNetInstallWorkflowStatus:(NSString *)outStr {
    
    // -------------------------------------------------------------
    //  Check if string begins with chosen prefix or with PERCENT:
    // -------------------------------------------------------------
    if ( [outStr hasPrefix:NBCWorkflowNetInstallLogPrefix] ) {
        
        // ----------------------------------------------------------------------------------------------
        //  Check for build steps in output, then try to update UI with a meaningful message or progress
        // ----------------------------------------------------------------------------------------------
        NSString *buildStep = [outStr componentsSeparatedByString:@"_"][2];
        
        // -------------------------------------------------------------
        //  "creatingImage", update progress bar from PERCENT: output
        // -------------------------------------------------------------
        if ( [buildStep isEqualToString:@"creatingImage"] ) {
            if ( [_delegate respondsToSelector:@selector(updateProgressStatus:workflow:)] ) {
                [_delegate updateProgressStatus:@"Creating disk image..." workflow:self];
            }
            
            // --------------------------------------------------------------------------------------
            //  "copyingSource", update progress bar from looping current file size of target volume
            // --------------------------------------------------------------------------------------
        } else if ( [buildStep isEqualToString:@"copyingSource"] ) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(checkDiskVolumeName:) name:DADiskDidAppearNotification object:nil];
            [nc addObserver:self selector:@selector(checkDiskVolumeName:) name:DADiskDidChangeNotification object:nil];
            
            // --------------------------------------------------------------------------------------
            //  "buildingBooter", update progress bar with static value
            // --------------------------------------------------------------------------------------
        } else if ( [buildStep isEqualToString:@"buildingBooter"] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setCopyComplete:YES];
                [self->_delegate updateProgressStatus:@"Preparing the kernel and boot loader for the boot image..." workflow:self];
                [self->_delegate updateProgressBar:80];
            });
            
            // --------------------------------------------------------------------------------------
            //  "finishingUp", update progress bar with static value
            // --------------------------------------------------------------------------------------
        } else if ( [buildStep isEqualToString:@"finishingUp"] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_delegate updateProgressStatus:@"Performing post install cleanup..." workflow:self];
                [self->_delegate updateProgressBar:85];
            });
        }
        
        // ---------------------------------------------------------
        //  Read percent value from output and pass to progress bar
        // ---------------------------------------------------------
    } else if ( [outStr containsString:@"PERCENT:"] ) {
        NSString *progressPercentString = [outStr componentsSeparatedByString:@":"][1] ;
        double progressPercent = [progressPercentString doubleValue];
        [self updateProgressBar:progressPercent];
    }
} // updateNetInstallWorkflowStatus:stdErr

- (void)checkDiskVolumeName:(id)sender {
    
    // --------------------------------------------------------------------------------
    //  Verify that the volumeName is the expected NBI volume name.
    //  Verify that the disk that's mounting has mounted completely (have a volumeURL)
    // --------------------------------------------------------------------------------
    NBCDisk *disk = [sender object];
    if ( [[disk volumeName] isEqualToString:_nbiVolumeName] ) {
        NSURL *diskVolumeURL = [disk volumeURL];
        if ( diskVolumeURL != nil ) {
            [self setCopyComplete:NO];
            [self setNbiVolumePath:[[disk volumeURL] path]];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc removeObserver:self name:DADiskDidAppearNotification object:nil];
            [nc removeObserver:self name:DADiskDidChangeNotification object:nil];
            
            [self updateProgressBarCopy];
        }
    }
} // checkDiskVolumeName

- (void)updateProgressBarCopy {
    
    // ---------------------------------------------------
    //  Loop to check volume size and update progress bar
    // ---------------------------------------------------
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(checkCopyProgress:)
                                   userInfo:nil
                                    repeats:YES];
} // updateProgressBarCopy

-(void)checkCopyProgress:(NSTimer *)timer {
    
    // -------------------------------------------------
    //  Get attributes for volume URL mounted by script
    // -------------------------------------------------
    NSError *error;
    NSDictionary *volumeAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:_nbiVolumePath error:&error];
    if ( [volumeAttributes count] != 0 ) {
        
        // -------------------------------------------------
        //  Calculate used size and update progress bar
        // -------------------------------------------------
        double maxSize = [volumeAttributes[NSFileSystemSize] doubleValue];
        double freeSize = [volumeAttributes[NSFileSystemFreeSize] doubleValue];
        double volumeCurrentSize = ( maxSize - freeSize );
        NSString *fileSizeString = [NSByteCountFormatter stringFromByteCount:(long long)volumeCurrentSize countStyle:NSByteCountFormatterCountStyleDecimal];
        NSString *fileSizeOriginal = [NSByteCountFormatter stringFromByteCount:(long long)_netInstallVolumeSize countStyle:NSByteCountFormatterCountStyleDecimal];
        
        if ( _netInstallVolumeSize <= volumeCurrentSize || _copyComplete == YES ) {
            [timer invalidate];
            timer = NULL;
        } else {
            double precentage = (((40 * volumeCurrentSize)/_netInstallVolumeSize) + 40);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_delegate updateProgressStatus:[NSString stringWithFormat:@"Copying BaseSystem.dmg... %@/%@", fileSizeString, fileSizeOriginal] workflow:self];
                [self->_delegate updateProgressBar:precentage];
            });
        }
    } else {
        [timer invalidate];
        timer = NULL;
        DDLogError(@"[ERROR] Could not get file attributes for volume: %@", _nbiVolumePath);
        DDLogError(@"[ERROR] %@", error);
    }
} // checkCopyProgress

- (void)updateProgressBarValue:(double)value {
    if ( value <= 0 ) {
        return;
    }
    double precentage = (40 * value)/[@100 doubleValue];
    [self->_delegate updateProgressStatus:[NSString stringWithFormat:@"Creating disk image... %d%%", (int)value] workflow:self];
    [self->_delegate updateProgressBar:precentage];
    
} // updateProgressBar

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NBCWorkflowProgressDelegate (Required but unused/passed on)
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateProgressStatus:(NSString *)statusMessage workflow:(id)workflow {
    if ( _delegate && [_delegate respondsToSelector:@selector(updateProgressStatus:workflow:)] ) {
        [_delegate updateProgressStatus:statusMessage workflow:workflow];
    }
}
- (void)updateProgressBar:(double)value {
    if ( _delegate && [_delegate respondsToSelector:@selector(updateProgressBar:)]) {
        [_delegate updateProgressBar:value];
    }
}
- (void)updateProgressStatus:(NSString *)statusMessage {
    if ( _delegate && [_delegate respondsToSelector:@selector(updateProgressStatus:)]) {
        [_delegate updateProgressStatus:statusMessage];
    }
}
- (void)logDebug:(NSString *)logMessage {
    if ( _delegate && [_delegate respondsToSelector:@selector(logDebug:)]) {
        [_delegate logDebug:logMessage];
    }
}
- (void)logInfo:(NSString *)logMessage {
    if ( _delegate && [_delegate respondsToSelector:@selector(logInfo:)]) {
        [_delegate logInfo:logMessage];
    }
}
- (void)logWarn:(NSString *)logMessage {
    if ( _delegate && [_delegate respondsToSelector:@selector(logWarn:)]) {
        [_delegate logWarn:logMessage];
    }
}
- (void)logError:(NSString *)logMessage {
    if ( _delegate && [_delegate respondsToSelector:@selector(logError:)]) {
        [_delegate logError:logMessage];
    }
}
- (void)logStdErr:(NSString *)stdErrString {
    if ( _delegate && [_delegate respondsToSelector:@selector(logStdErr:)]) {
        [_delegate logStdErr:stdErrString];
    }
}

@end
