//
//  NBCIMSettingsViewController.h
//  NBICreator
//
//  Created by Erik Berglund on 2015-04-29.
//  Copyright (c) 2015 NBICreator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NBCImagrDropViewImage.h"
#import "NBCAlerts.h"

#import "NBCSource.h"
#import "NBCTarget.h"
#import "NBCSystemImageUtilitySource.h"
#import "NBCTemplatesController.h"

#import "NBCDownloader.h"
#import "NBCDownloaderGitHub.h"
#import "NBCWorkflowResourcesController.h"

#define BasicTableViewDragAndDropDataType @"BasicTableViewDragAndDropDataType"

@interface NBCImagrSettingsViewController : NSViewController <NBCDownloaderDelegate, NBCDownloaderGitHubDelegate, NBCTemplatesDelegate, NBCAlertDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property NSMutableArray *certificateTableViewContents;
@property NSMutableArray *packagesTableViewContents;

@property NSMutableDictionary *keyboardLayoutDict;
@property NSDictionary *languageDict;

// ------------------------------------------------------
//  Constraints
// ------------------------------------------------------
@property (strong) IBOutlet NSLayoutConstraint *constraintLocalPathToImagrVersion;
@property (strong) IBOutlet NSLayoutConstraint *constraintConfigurationURLToImagrVersion;
@property (strong) IBOutlet NSLayoutConstraint *constraintTemplatesBoxHeight;
@property (strong) IBOutlet NSLayoutConstraint *constraintSavedTemplatesToTool;

// ------------------------------------------------------
//  Class Instance Properties
// ------------------------------------------------------
@property NBCSource *source;
@property NBCTarget *target;
@property NBCSystemImageUtilitySource *siuSource;
@property NBCTemplatesController *templates;
@property NBCWorkflowResourcesController *resourcesController;

// ------------------------------------------------------
//  Tool
// ------------------------------------------------------
@property (weak) IBOutlet NSTextField *textFieldSIUVersionLabel;
@property (weak) IBOutlet NSTextField *textFieldSIUVersionString;
@property (weak) IBOutlet NSPopUpButton *popUpButtonTool;
- (IBAction)popUpButtonTool:(id)sender;

// ------------------------------------------------------
//  Templates
// ------------------------------------------------------
@property NSURL *templatesFolderURL;
@property NSString *selectedTemplate;
@property NSMutableDictionary *templatesDict;
@property (weak) IBOutlet NSPopUpButton *popUpButtonTemplates;
- (IBAction)popUpButtonTemplates:(id)sender;

// ------------------------------------------------------
//  TabView General
// ------------------------------------------------------
@property (weak) IBOutlet NBCImagrDropViewImageIcon *imageViewIcon;
@property (weak) IBOutlet NSTextField *textFieldNBIName;
@property (weak) IBOutlet NSTextField *textFieldNBINamePreview;
@property (weak) IBOutlet NSTextField *textFieldIndex;
@property (weak) IBOutlet NSTextField *textFieldIndexPreview;
@property (weak) IBOutlet NSTextField *textFieldNBIDescription;
@property (weak) IBOutlet NSTextField *textFieldNBIDescriptionPreview;
@property (weak) IBOutlet NSTextField *textFieldDestinationFolder;
@property (weak) IBOutlet NSPopUpButton *popUpButtonProtocol;
@property (weak) IBOutlet NSPopUpButton *popUpButtonLanguage;
@property (weak) IBOutlet NSPopUpButton *popUpButtonKeyboardLayout;
@property (weak) IBOutlet NSButton *checkboxAvailabilityEnabled;
@property (weak) IBOutlet NSButton *checkboxAvailabilityDefault;
@property (weak) IBOutlet NSButton *buttonChooseDestinationFolder;
- (IBAction)buttonChooseDestinationFolder:(id)sender;

// ------------------------------------------------------
//  TabView Imagr Settings
// ------------------------------------------------------
@property NSArray *imagrVersions;
@property NSDictionary *imagrVersionsDownloadLinks;
@property (weak) IBOutlet NSPopUpButton *popUpButtonImagrVersion;
- (IBAction)popUpButtonImagrVersion:(id)sender;
@property (weak) IBOutlet NSTextField *textFieldImagrLocalPathLabel;
@property (weak) IBOutlet NSTextField *textFieldImagrLocalPath;
@property (weak) IBOutlet NSButton *buttonChooseImagrLocalPath;
- (IBAction)buttonChooseImagrLocalPath:(id)sender;
@property (weak) IBOutlet NSTextField *textFieldConfigurationURL;

@property (weak) IBOutlet NSTextField *textFieldReportingURL;


@property (weak) IBOutlet NSButton *checkboxDisableWiFi;

@property (weak) IBOutlet NSImageView *imageViewNetworkWarning;
@property (weak) IBOutlet NSTextField *textFieldNetworkWarning;

// ------------------------------------------------------
//  TabView Options
// ------------------------------------------------------
@property (weak) IBOutlet NSTextField *textFieldARDLogin;
@property (weak) IBOutlet NSTextField *textFieldARDPassword;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldARDPassword;
@property (weak) IBOutlet NSTextField *textFieldNetworkTimeServer;

// ------------------------------------------------------
//  TabView Extras
// ------------------------------------------------------
@property (weak) IBOutlet NSTableView *tableViewCertificates;
@property (weak) IBOutlet NSTableView *tableViewPackages;
@property (weak) IBOutlet NSButton *buttonAddCertificate;
- (IBAction)buttonAddCertificate:(id)sender;
@property (weak) IBOutlet NSButton *buttonRemoveCertificate;
- (IBAction)buttonRemoveCertificate:(id)sender;

@property (weak) IBOutlet NSButton *buttonAddPackage;
- (IBAction)buttonAddPackage:(id)sender;
@property (weak) IBOutlet NSButton *buttonRemovePackage;
- (IBAction)buttonRemovePackage:(id)sender;



// ------------------------------------------------------
//  UI Binding Properties
// ------------------------------------------------------
@property NSString *nbiCreationTool;
@property BOOL useSystemImageUtility;

@property BOOL isNBI;

@property BOOL nbiEnabled;
@property BOOL nbiDefault;
@property NSString *nbiName;
@property NSString *nbiIcon;
@property NSString *nbiIconPath;
@property NSString *nbiIndex;
@property NSString *nbiProtocol;
@property NSString *nbiLanguage;
@property NSString *nbiKeyboardLayout;
@property NSString *nbiDescription;
@property NSString *destinationFolder;

@property BOOL disableWiFi;
@property BOOL displaySleep;
@property BOOL includeSystemUIServer;
@property NSString *displaySleepMinutes;
@property NSString *ardLogin;
@property NSString *ardPassword;
@property BOOL showARDPassword;
@property NSString *networkTimeServer;


@property BOOL includeImagrPreReleaseVersionsEnabled;
@property BOOL includeImagrPreReleaseVersions;
@property NSString *imagrVersion;
@property NSString *imagrConfigurationURL;
@property NSString *imagrReportingURL;
@property BOOL imagrUseLocalVersion;
@property NSString *imagrLocalVersionPath;


// ------------------------------------------------------
//  Instance Methods
// ------------------------------------------------------
- (void)buildNBI;
- (void)verifyBuildButton;
- (void)verifySettings;
- (BOOL)haveSettingsChanged;
- (void)updateUISettingsFromDict:(NSDictionary *)settingsDict;
- (void)updateUISettingsFromURL:(NSURL *)url;
- (void)saveUISettingsWithName:(NSString *)name atUrl:(NSURL *)settingsURL;
- (void)expandVariablesForCurrentSettings;

@end
