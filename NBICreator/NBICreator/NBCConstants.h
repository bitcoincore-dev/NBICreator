//
//  NBCConstants.h
//  NBICreator
//
//  Created by Erik Berglund on 2015-05-06.
//  Copyright (c) 2015 NBICreator. All rights reserved.
//

#import <Foundation/Foundation.h>

// --------------------------------------------------------------
//  NBICreator Application
// --------------------------------------------------------------
extern NSString *const NBCBundleIdentifier;
extern NSString *const NBCBundleIdentifierHelper;


extern NSString *const NBCWorkflowTypeNetInstall;
extern NSString *const NBCWorkflowTypeDeployStudio;
extern NSString *const NBCWorkflowTypeImagr;

// --------------------------------------------------------------
//  Folders
// --------------------------------------------------------------
extern NSString *const NBCFolderTemplates;
extern NSString *const NBCFolderTemplatesNetInstall;
extern NSString *const NBCFolderTemplatesDeployStudio;
extern NSString *const NBCFolderTemplatesImagr;
extern NSString *const NBCFolderTemplatesCustom;
extern NSString *const NBCFolderTemplatesDisabled;
extern NSString *const NBCFolderResources;
extern NSString *const NBCFolderResourcesPython;
extern NSString *const NBCFolderResourcesImagr;
extern NSString *const NBCFolderResourcesDeployStudio;
extern NSString *const NBCFolderResourcesSource;

// --------------------------------------------------------------
//  Files
// --------------------------------------------------------------
extern NSString *const NBCFileResourcesDict;
extern NSString *const NBCFileDownloadsDict;
extern NSString *const NBCFilePathNBIIconImagr;
extern NSString *const NBCFilePathNBIIconNetInstall;
extern NSString *const NBCFilePathNBIIconDeployStudio;
extern NSString *const NBCFileNameImagrDefaults;

extern NSString *const NBCPathPreferencesGlobal;
extern NSString *const NBCPathPreferencesHIToolbox;

// --------------------------------------------------------------
//  User Defaults
// --------------------------------------------------------------
extern NSString *const NBCUserDefaultsIndexCounter;
extern NSString *const NBCUserDefaultsNetBootSelection;
extern NSString *const NBCUserDefaultsDateFormatString;
extern NSString *const NBCUserDefaultsLogLevel;

// --------------------------------------------------------------
//  Menu Items
// --------------------------------------------------------------
extern NSString *const NBCMenuItemUntitled;
extern NSString *const NBCMenuItemNew;
extern NSString *const NBCMenuItemSave;
extern NSString *const NBCMenuItemSaveAs;
extern NSString *const NBCMenuItemDelete;
extern NSString *const NBCMenuItemShowInFinder;
extern NSString *const NBCMenuItemImagrVersionLatest;
extern NSString *const NBCMenuItemImagrVersionLocal;
extern NSString *const NBCMenuItemDeployStudioVersionLatest;
extern NSString *const NBCMenuItemRestoreOriginalIcon;
extern NSString *const NBCMenuItemRestoreOriginalBackground;
extern NSString *const NBCMenuItemNoSelection;
extern NSString *const NBCMenuItemNBICreator;
extern NSString *const NBCMenuItemSystemImageUtility;
extern NSString *const NBCMenuItemCurrent;

// --------------------------------------------------------------
//  Template
// --------------------------------------------------------------
extern NSString *const NBCSettingsFileName;
extern NSString *const NBCSettingsFileVersion;

// --------------------------------------------------------------
//  Template Settings Main
// --------------------------------------------------------------
extern NSString *const NBCSettingsNameKey;
extern NSString *const NBCSettingsTypeKey;
extern NSString *const NBCSettingsTypeImagr;
extern NSString *const NBCSettingsTypeImagrDefaultSettings;
extern NSString *const NBCSettingsTypeNetInstall;
extern NSString *const NBCSettingsTypeNetInstallDefaultSettings;
extern NSString *const NBCSettingsTypeDeployStudio;
extern NSString *const NBCSettingsTypeDeployStudioDefaultSettings;
extern NSString *const NBCSettingsTypeCustom;
extern NSString *const NBCSettingsVersionKey;
extern NSString *const NBCSettingsSettingsKey;

// --------------------------------------------------------------
//  Template Settings General
// --------------------------------------------------------------
extern NSString *const NBCSettingsNBIName;
extern NSString *const NBCSettingsNBIIndex;
extern NSString *const NBCSettingsNBIProtocol;
extern NSString *const NBCSettingsNBIEnabled;
extern NSString *const NBCSettingsNBIDefault;
extern NSString *const NBCSettingsNBILanguage;
extern NSString *const NBCSettingsNBIKeyboardLayout;
extern NSString *const NBCSettingsNBIDescription;
extern NSString *const NBCSettingsNBIDestinationFolder;
extern NSString *const NBCSettingsNBIIcon;

extern NSString *const NBCSettingsNBIKeyboardLayoutName;

// --------------------------------------------------------------
//  Template Settings Options
// --------------------------------------------------------------
extern NSString *const NBCSettingsDisableWiFiKey;
extern NSString *const NBCSettingsDisplaySleepKey;
extern NSString *const NBCSettingsDisplaySleepMinutesKey;
extern NSString *const NBCSettingsIncludeSystemUIServerKey;
extern NSString *const NBCSettingsARDLoginKey;
extern NSString *const NBCSettingsARDPasswordKey;
extern NSString *const NBCSettingsNBICreationToolKey;
extern NSString *const NBCSettingsNetworkTimeServerKey;

// --------------------------------------------------------------
//  Template Settings Extra
// --------------------------------------------------------------
extern NSString *const NBCSettingsCertificates;
extern NSString *const NBCSettingsPackages;

// --------------------------------------------------------------
//  Template Settings Imagr
// --------------------------------------------------------------
extern NSString *const NBCSettingsImagrVersion;
extern NSString *const NBCSettingsImagrIncludePreReleaseVersions;
extern NSString *const NBCSettingsImagrConfigurationURL;
extern NSString *const NBCSettingsImagrServerURLKey;
extern NSString *const NBCSettingsImagrDownloadURL;
extern NSString *const NBCSettingsImagrDownloadPython;
extern NSString *const NBCSettingsImagrRCImaging;
extern NSString *const NBCSettingsImagrRCImagingNBICreator;
extern NSString *const NBCSettingsImagrUseLocalVersion;
extern NSString *const NBCSettingsImagrLocalVersionPath;
extern NSString *const NBCSettingsImagrSourceIsNBI;

extern NSString *const NBCSettingsImagrVersionLatest;

// --------------------------------------------------------------
//  Template Settings DeployStudio
// --------------------------------------------------------------
extern NSString *const NBCSettingsDeployStudioTimeServerKey;
extern NSString *const NBCSettingsDeployStudioUseCustomServersKey;
extern NSString *const NBCSettingsDeployStudioServerURL1Key;
extern NSString *const NBCSettingsDeployStudioServerURL2Key;
extern NSString *const NBCSettingsDeployStudioDisableVersionMismatchAlertsKey;
extern NSString *const NBCSettingsDeployStudioRuntimeLoginKey;
extern NSString *const NBCSettingsDeployStudioRuntimePasswordKey;
extern NSString *const NBCSettingsDeployStudioDisplayLogWindowKey;
extern NSString *const NBCSettingsDeployStudioSleepKey;
extern NSString *const NBCSettingsDeployStudioSleepDelayKey;
extern NSString *const NBCSettingsDeployStudioRebootKey;
extern NSString *const NBCSettingsDeployStudioRebootDelayKey;
extern NSString *const NBCSettingsDeployStudioIncludePythonKey;
extern NSString *const NBCSettingsDeployStudioIncludeRubyKey;
extern NSString *const NBCSettingsDeployStudioUseCustomTCPStackKey;
extern NSString *const NBCSettingsDeployStudioDisableWirelessSupportKey;
extern NSString *const NBCSettingsDeployStudioUseSMB1Key;
extern NSString *const NBCSettingsDeployStudioUseCustomRuntimeTitleKey;
extern NSString *const NBCSettingsDeployStudioRuntimeTitleKey;
extern NSString *const NBCSettingsDeployStudioUseCustomBackgroundImageKey;
extern NSString *const NBCSettingsDeployStudioCustomBackgroundImageKey;

// --------------------------------------------------------------
//  Template Settings Python
// --------------------------------------------------------------
extern NSString *const NBCSettingsPythonVersion;
extern NSString *const NBCSettingsPythonDownloadURL;
extern NSString *const NBCSettingsPythonDefaultVersion;

// --------------------------------------------------------------
//  NBImageInfo
// --------------------------------------------------------------
extern NSString *const NBCNBImageInfoDictNameKey;
extern NSString *const NBCNBImageInfoDictDescriptionKey;
extern NSString *const NBCNBImageInfoDictIndexKey;
extern NSString *const NBCNBImageInfoDictIsDefaultKey;
extern NSString *const NBCNBImageInfoDictIsEnabledKey;
extern NSString *const NBCNBImageInfoDictLanguageKey;
extern NSString *const NBCNBImageInfoDictProtocolKey;

// --------------------------------------------------------------
//  Workflow Types
// --------------------------------------------------------------
extern NSString *const NBCWorkflowNBI;
extern NSString *const NBCWorkflowNBIResources;
extern NSString *const NBCWorkflowNBIModify;

// --------------------------------------------------------------
//  Notifications
// --------------------------------------------------------------

// Workflows
extern NSString *const NBCNotificationAddWorkflowItemToQueue;
extern NSString *const NBCNotificationWorkflowCompleteNBI;
extern NSString *const NBCNotificationWorkflowCompleteResources;
extern NSString *const NBCNotificationWorkflowCompleteModifyNBI;
extern NSString *const NBCNotificationWorkflowFailed;

// Workflows UserInfoKeys
extern NSString *const NBCNotificationAddWorkflowItemToQueueUserInfoWorkflowItem;
extern NSString *const NBCNotificationRemoveWorkflowItemUserInfoWorkflowItem;

// Imagr
extern NSString *const NBCNotificationImagrUpdateSource;
extern NSString *const NBCNotificationImagrRemovedSource;
extern NSString *const NBCNotificationImagrUpdateNBIIcon;
extern NSString *const NBCNotificationImagrVerifyDroppedSource;

// DeployStudio
extern NSString *const NBCNotificationDeployStudioUpdateSource;
extern NSString *const NBCNotificationDeployStudioRemovedSource;
extern NSString *const NBCNotificationDeployStudioUpdateNBIIcon;
extern NSString *const NBCNotificationDeployStudioUpdateNBIBackground;
extern NSString *const NBCNotificationDeployStudioAddBonjourService;
extern NSString *const NBCNotificationDeployStudioRemoveBonjourService;
extern NSString *const NBCNotificationDeployStudioVerifyDroppedSource;

// NetInstall
extern NSString *const NBCNotificationNetInstallUpdateSource;
extern NSString *const NBCNotificationNetInstallRemovedSource;
extern NSString *const NBCNotificationNetInstallUpdateNBIIcon;
extern NSString *const NBCNotificationNetInstallVerifyDroppedSource;

// Imagr / DeployStudio / NetInstall UserInfoKeys
extern NSString *const NBCNotificationVerifyDroppedSourceUserInfoSourceURL;

// Update Button Build
extern NSString *const NBCNotificationUpdateButtonBuild;

// Update Button Build UserInfoKeys
extern NSString *const NBCNotificationUpdateButtonBuildUserInfoButtonState;

// Update Source UserInfoKeys
extern NSString *const NBCNotificationUpdateSourceUserInfoSource;
extern NSString *const NBCNotificationUpdateSourceUserInfoTarget;

// Update NBI Icon UserInfoKeys
extern NSString *const NBCNotificationUpdateNBIIconUserInfoIconURL;

// Update NBI Background UserInfoKeys
extern NSString *const NBCNotificationUpdateNBIBackgroundUserInfoIconURL;

// --------------------------------------------------------------
//  Imagr
// --------------------------------------------------------------
extern NSString *const NBCImagrApplicationURL;
extern NSString *const NBCImagrConfigurationPlistURL;
extern NSString *const NBCImagrRCImagingURL;

// --------------------------------------------------------------
//  System Image Utility
// --------------------------------------------------------------
extern NSString *const NBCSystemImageUtilityScriptCreateCommon;
extern NSString *const NBCSystemImageUtilityScriptCreateNetBoot;
extern NSString *const NBCSystemImageUtilityScriptCreateNetInstall;
extern NSString *const NBCSystemImageUtilityNetBootImageSize;

// --------------------------------------------------------------
//  Buttons
// --------------------------------------------------------------
extern NSString *const NBCButtonTitleCancel;
extern NSString *const NBCButtonTitleContinue;
extern NSString *const NBCButtonTitleOK;
extern NSString *const NBCButtonTitleSave;
extern NSString *const NBCButtonTitleQuit;

// --------------------------------------------------------------
//  Alerts
// --------------------------------------------------------------
extern NSString *const NBCAlertTagKey;
extern NSString *const NBCAlertTagSettingsWarning;
extern NSString *const NBCAlertTagSettingsUnsaved;
extern NSString *const NBCAlertTagSettingsUnsavedQuit;
extern NSString *const NBCAlertTagSettingsUnsavedBuild;
extern NSString *const NBCAlertWorkflowItemKey;
extern NSString *const NBCAlertTagWorkflowRunningQuit;

extern NSString *const NBCAlertUserInfoSelectedTemplate;
extern NSString *const NBCAlertUserInfoTemplateURL;

extern NSString *const NBCErrorDomain;

extern NSString *const NBCWorkflowNetInstallLogPrefix;

extern NSString *const NBCDeployStudioRepository;

extern NSString *const NBCAlertTagDeleteTemplate;

// PYTHON

extern NSString *const NBCPythonRepositoryURL;
extern NSString *const NBCPythonInstallerPathInDiskImage;

extern NSString *const NBCSettingsError;
extern NSString *const NBCSettingsWarning;

extern NSString *const NBCDeployStudioTabTitleRuntime;
extern NSString *const NBCDeployStudioBackgroundDefaultPath;
extern NSString *const NBCDeployStudioBackgroundImageDefaultPath;

extern NSString *const NBCSettingsSourceItemsKey;
extern NSString *const NBCSettingsSourceItemsPathKey;
extern NSString *const NBCSettingsSourceItemsRegexKey;
extern NSString *const NBCSettingsSourceItemsCacheFolderKey;

extern NSString *const NBCImagrBundleIdentifier;

// GITHUB



extern NSString *const NBCDownloaderTag;
extern NSString *const NBCDownloaderTagPython;
extern NSString *const NBCDownloaderTagImagr;
extern NSString *const NBCDownloaderTagDeployStudio;
extern NSString *const NBCDownloaderVersion;

extern NSString *const NBCTargetFolderMinFreeSizeInGB;

// --------------------------------------------------------------
//  Workflow Copy
// --------------------------------------------------------------
extern NSString *const NBCWorkflowCopyType;
extern NSString *const NBCWorkflowCopy;
extern NSString *const NBCWorkflowCopySourceURL;
extern NSString *const NBCWorkflowCopyTargetURL;
extern NSString *const NBCWorkflowCopyAttributes;
extern NSString *const NBCWorkflowCopyRegex;
extern NSString *const NBCWorkflowCopyRegexSourceFolderURL;
extern NSString *const NBCWorkflowCopyRegexTargetFolderURL;

// --------------------------------------------------------------
//  Workflow Modify
// --------------------------------------------------------------
extern NSString *const NBCWorkflowModify;
extern NSString *const NBCWorkflowModifyAttributes;
extern NSString *const NBCWorkflowModifyTargetURL;
extern NSString *const NBCWorkflowModifyContent;
extern NSString *const NBCWorkflowModifyFileType;
extern NSString *const NBCWorkflowModifyFileTypePlist;
extern NSString *const NBCWorkflowModifyFileTypeGeneric;
extern NSString *const NBCWorkflowModifyFileTypeFolder;
extern NSString *const NBCWorkflowModifyFileTypeDelete;

// --------------------------------------------------------------
//  Workflow Install
// --------------------------------------------------------------
extern NSString *const NBCWorkflowInstall;
extern NSString *const NBCWorkflowInstallerName;
extern NSString *const NBCWorkflowInstallerSourceURL;
extern NSString *const NBCWorkflowInstallerChoiceChangeXML;


// --------------------------------------------------------------
//  Imagr
// --------------------------------------------------------------
extern NSString *const NBCImagrApplicationTargetURL;
extern NSString *const NBCImagrApplicationNBICreatorTargetURL;
extern NSString *const NBCImagrConfigurationPlistTargetURL;
extern NSString *const NBCImagrConfigurationPlistNBICreatorTargetURL;
extern NSString *const NBCImagrRCImagingTargetURL;
extern NSString *const NBCImagrRCImagingNBICreatorTargetURL;
extern NSString *const NBCImagrRCInstallTargetURL;
extern NSString *const NBCImagrGitHubRepository;


// --------------------------------------------------------------
//  Certificate TableView Keys
// --------------------------------------------------------------
extern NSString *const NBCDictionaryKeyCertificate;
extern NSString *const NBCDictionaryKeyCertificateURL;
extern NSString *const NBCDictionaryKeyCertificateName;
extern NSString *const NBCDictionaryKeyCertificateIcon;
extern NSString *const NBCDictionaryKeyCertificateAuthority;
extern NSString *const NBCDictionaryKeyCertificateSignature;
extern NSString *const NBCDictionaryKeyCertificateSelfSigned;
extern NSString *const NBCDictionaryKeyCertificateSerialNumber;
extern NSString *const NBCDictionaryKeyCertificateNotValidBeforeDate;
extern NSString *const NBCDictionaryKeyCertificateNotValidAfterDate;
extern NSString *const NBCDictionaryKeyCertificateExpirationString;
extern NSString *const NBCDictionaryKeyCertificateExpired;


extern NSString *const NBCDictionaryKeyPackagePath;
extern NSString *const NBCDictionaryKeyPackageName;


extern NSString *const NBCCertificatesNBICreatorTargetURL;
extern NSString *const NBCCertificatesTargetURL;
extern NSString *const NBCScriptsNBICreatorTargetPath;
extern NSString *const NBCScriptsTargetPath;


extern NSString *const NBCNetworkTimeServerDefault;

extern NSString *const NBCNBIDescriptionSIU;
extern NSString *const NBCNBIDescriptionNBC;

extern NSString *const NBCDiskDeviceModelDiskImage;

extern NSString *const NBCBonjourServiceDeployStudio;
extern NSString *const NBCDeployStudioLatestVersionURL;

extern NSString *const NBCResourcesDeployStudioLatestVersionKey;

extern NSString *const NBCAlertUserInfoBuildNBI;

extern NSString *const NBCHelpURL;

extern NSString *const NBCVariableIndexCounter;

extern NSString *const NBCTableViewIdentifierCertificates;
extern NSString *const NBCTableViewIdentifierPackages;