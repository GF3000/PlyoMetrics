import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @tagPerformance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get tagPerformance;

  /// No description provided for @cmjBaselineMeasurement.
  ///
  /// In en, this message translates to:
  /// **'CMJ Baseline Measurement'**
  String get cmjBaselineMeasurement;

  /// No description provided for @verticalJumpMetricsFlightTime.
  ///
  /// In en, this message translates to:
  /// **'Vertical jump metrics & flight time'**
  String get verticalJumpMetricsFlightTime;

  /// No description provided for @pleaseSelectAthleteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an athlete first'**
  String get pleaseSelectAthleteFirst;

  /// No description provided for @tagMonitoring.
  ///
  /// In en, this message translates to:
  /// **'MONITORING'**
  String get tagMonitoring;

  /// No description provided for @readinessFatigueTest.
  ///
  /// In en, this message translates to:
  /// **'Readiness / Fatigue Test'**
  String get readinessFatigueTest;

  /// No description provided for @dailyCnsRecoveryTracking.
  ///
  /// In en, this message translates to:
  /// **'Daily CNS & recovery tracking'**
  String get dailyCnsRecoveryTracking;

  /// No description provided for @completeCmjBaselineFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete a CMJ Baseline first'**
  String get completeCmjBaselineFirst;

  /// No description provided for @tagReactiveStrength.
  ///
  /// In en, this message translates to:
  /// **'REACTIVE STRENGTH'**
  String get tagReactiveStrength;

  /// No description provided for @rsiDropJumpTest.
  ///
  /// In en, this message translates to:
  /// **'RSI Drop Jump Test'**
  String get rsiDropJumpTest;

  /// No description provided for @groundContactEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Ground contact & efficiency'**
  String get groundContactEfficiency;

  /// No description provided for @selectAnAthleteFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an athlete first'**
  String get selectAnAthleteFirst;

  /// No description provided for @athleteRoster.
  ///
  /// In en, this message translates to:
  /// **'ATHLETE ROSTER'**
  String get athleteRoster;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @errorLoadingAthletes.
  ///
  /// In en, this message translates to:
  /// **'Error loading athletes'**
  String get errorLoadingAthletes;

  /// No description provided for @addAthlete.
  ///
  /// In en, this message translates to:
  /// **'Add Athlete'**
  String get addAthlete;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get navEvolution;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get navLog;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile coming soon!'**
  String get profileComingSoon;

  /// No description provided for @renameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename Group'**
  String get renameGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @confirmDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{groupName}\"?'**
  String confirmDeleteGroup(String groupName);

  /// No description provided for @newMeasurement.
  ///
  /// In en, this message translates to:
  /// **'New Measurement'**
  String get newMeasurement;

  /// No description provided for @cmjBaseline.
  ///
  /// In en, this message translates to:
  /// **'CMJ Baseline'**
  String get cmjBaseline;

  /// No description provided for @verticalJumpMetrics.
  ///
  /// In en, this message translates to:
  /// **'Vertical jump metrics'**
  String get verticalJumpMetrics;

  /// No description provided for @fatigueTest.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Test'**
  String get fatigueTest;

  /// No description provided for @dailyReadinessTracking.
  ///
  /// In en, this message translates to:
  /// **'Daily readiness tracking'**
  String get dailyReadinessTracking;

  /// No description provided for @rsiDropJump.
  ///
  /// In en, this message translates to:
  /// **'RSI Drop Jump'**
  String get rsiDropJump;

  /// No description provided for @cmjBaselineInstructions.
  ///
  /// In en, this message translates to:
  /// **'Record at least 1 jump to establish a baseline.\nMaximum 3 jumps allowed.'**
  String get cmjBaselineInstructions;

  /// No description provided for @recordJumpNumber.
  ///
  /// In en, this message translates to:
  /// **'Record Jump #{number}'**
  String recordJumpNumber(int number);

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @incompleteBaseline.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Baseline'**
  String get incompleteBaseline;

  /// No description provided for @incompleteBaselineMessage.
  ///
  /// In en, this message translates to:
  /// **'It is highly recommended to record at least 3 jumps to establish an accurate baseline and filter out anomalies. Are you sure you want to save?'**
  String get incompleteBaselineMessage;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get saveAnyway;

  /// No description provided for @noAthleteSelected.
  ///
  /// In en, this message translates to:
  /// **'No athlete selected'**
  String get noAthleteSelected;

  /// No description provided for @jumpNumber.
  ///
  /// In en, this message translates to:
  /// **'Jump #{number}'**
  String jumpNumber(int number);

  /// No description provided for @outlier.
  ///
  /// In en, this message translates to:
  /// **'Outlier'**
  String get outlier;

  /// No description provided for @flightTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'Flight time: {flightTime} ms  |  {fps} FPS'**
  String flightTimeInfo(String flightTime, String fps);

  /// No description provided for @calculatedAverage.
  ///
  /// In en, this message translates to:
  /// **'CALCULATED AVERAGE'**
  String get calculatedAverage;

  /// No description provided for @outliersExcluded.
  ///
  /// In en, this message translates to:
  /// **'Outliers excluded from average'**
  String get outliersExcluded;

  /// No description provided for @selectJumpMoment.
  ///
  /// In en, this message translates to:
  /// **'Select Jump Moment'**
  String get selectJumpMoment;

  /// No description provided for @pickVideoToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Pick a video to analyze'**
  String get pickVideoToAnalyze;

  /// No description provided for @analyzeJumpFromHere.
  ///
  /// In en, this message translates to:
  /// **'Analyze Jump from Here'**
  String get analyzeJumpFromHere;

  /// No description provided for @pickVideoFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick Video from Gallery'**
  String get pickVideoFromGallery;

  /// No description provided for @landingFrameAfterTakeoff.
  ///
  /// In en, this message translates to:
  /// **'Landing frame must be after takeoff frame'**
  String get landingFrameAfterTakeoff;

  /// No description provided for @framesInOrder.
  ///
  /// In en, this message translates to:
  /// **'Frames must be in order: Landing 1 < Takeoff < Landing 2'**
  String get framesInOrder;

  /// No description provided for @frameAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Frame Analysis'**
  String get frameAnalysis;

  /// No description provided for @extractingFrames.
  ///
  /// In en, this message translates to:
  /// **'Extracting Frames'**
  String get extractingFrames;

  /// No description provided for @processingVideoAtFps.
  ///
  /// In en, this message translates to:
  /// **'Processing video at {fps} FPS'**
  String processingVideoAtFps(String fps);

  /// No description provided for @processingVideo.
  ///
  /// In en, this message translates to:
  /// **'Processing video at ...'**
  String get processingVideo;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @extractionFailed.
  ///
  /// In en, this message translates to:
  /// **'Extraction Failed'**
  String get extractionFailed;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @noFramesExtracted.
  ///
  /// In en, this message translates to:
  /// **'No frames extracted'**
  String get noFramesExtracted;

  /// No description provided for @frameCounter.
  ///
  /// In en, this message translates to:
  /// **'Frame {current} / {total}'**
  String frameCounter(int current, int total);

  /// No description provided for @fpsDisplay.
  ///
  /// In en, this message translates to:
  /// **'{fps} FPS'**
  String fpsDisplay(String fps);

  /// No description provided for @msDisplay.
  ///
  /// In en, this message translates to:
  /// **'{time} ms'**
  String msDisplay(String time);

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @landing1.
  ///
  /// In en, this message translates to:
  /// **'Landing 1'**
  String get landing1;

  /// No description provided for @takeoff.
  ///
  /// In en, this message translates to:
  /// **'Takeoff'**
  String get takeoff;

  /// No description provided for @landing2.
  ///
  /// In en, this message translates to:
  /// **'Landing 2'**
  String get landing2;

  /// No description provided for @markTakeoff.
  ///
  /// In en, this message translates to:
  /// **'Mark Takeoff'**
  String get markTakeoff;

  /// No description provided for @markLanding.
  ///
  /// In en, this message translates to:
  /// **'Mark Landing'**
  String get markLanding;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @flight.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get flight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @rsi.
  ///
  /// In en, this message translates to:
  /// **'RSI'**
  String get rsi;

  /// No description provided for @flightTime.
  ///
  /// In en, this message translates to:
  /// **'Flight Time'**
  String get flightTime;

  /// No description provided for @errorMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorMarginLabel;

  /// No description provided for @confirmJump.
  ///
  /// In en, this message translates to:
  /// **'Confirm Jump'**
  String get confirmJump;

  /// No description provided for @countermovementJumpCMJ.
  ///
  /// In en, this message translates to:
  /// **'Countermovement Jump (CMJ)'**
  String get countermovementJumpCMJ;

  /// No description provided for @currentJump.
  ///
  /// In en, this message translates to:
  /// **'CURRENT JUMP'**
  String get currentJump;

  /// No description provided for @baselineMax.
  ///
  /// In en, this message translates to:
  /// **'BASELINE MAX'**
  String get baselineMax;

  /// No description provided for @fatigueStatus.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Status'**
  String get fatigueStatus;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @moderateFatigue.
  ///
  /// In en, this message translates to:
  /// **'Moderate Fatigue'**
  String get moderateFatigue;

  /// No description provided for @highFatigue.
  ///
  /// In en, this message translates to:
  /// **'High Fatigue'**
  String get highFatigue;

  /// No description provided for @fatigueOptimalMessage.
  ///
  /// In en, this message translates to:
  /// **'Athlete is well recovered and ready for high-intensity training.'**
  String get fatigueOptimalMessage;

  /// No description provided for @fatigueModerateMessage.
  ///
  /// In en, this message translates to:
  /// **'Some fatigue detected. Consider moderate training loads.'**
  String get fatigueModerateMessage;

  /// No description provided for @fatigueHighMessage.
  ///
  /// In en, this message translates to:
  /// **'Significant fatigue present. Recommend recovery or light activity.'**
  String get fatigueHighMessage;

  /// No description provided for @baseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get baseline;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @recordDailyJump.
  ///
  /// In en, this message translates to:
  /// **'Record Daily Jump'**
  String get recordDailyJump;

  /// No description provided for @saveTest.
  ///
  /// In en, this message translates to:
  /// **'Save Test'**
  String get saveTest;

  /// No description provided for @discardResult.
  ///
  /// In en, this message translates to:
  /// **'Discard Result'**
  String get discardResult;

  /// No description provided for @newPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'New Personal Best!'**
  String get newPersonalBest;

  /// No description provided for @pbDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your jump of {height}cm exceeded the current baseline. Please redo the CMJ Baseline measurement to ensure accurate fatigue tracking.'**
  String pbDialogMessage(String height);

  /// No description provided for @updateBaseline.
  ///
  /// In en, this message translates to:
  /// **'Update Baseline'**
  String get updateBaseline;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @dropHeight.
  ///
  /// In en, this message translates to:
  /// **'DROP HEIGHT'**
  String get dropHeight;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'{height} cm'**
  String heightCm(int height);

  /// No description provided for @contactTime.
  ///
  /// In en, this message translates to:
  /// **'CONTACT TIME'**
  String get contactTime;

  /// No description provided for @flightTimeCaps.
  ///
  /// In en, this message translates to:
  /// **'FLIGHT TIME'**
  String get flightTimeCaps;

  /// No description provided for @reactiveStrengthIndex.
  ///
  /// In en, this message translates to:
  /// **'REACTIVE STRENGTH INDEX'**
  String get reactiveStrengthIndex;

  /// No description provided for @rsiError.
  ///
  /// In en, this message translates to:
  /// **'± {delta} error'**
  String rsiError(String delta);

  /// No description provided for @recordDropJump.
  ///
  /// In en, this message translates to:
  /// **'Record Drop Jump'**
  String get recordDropJump;

  /// No description provided for @saveTestResult.
  ///
  /// In en, this message translates to:
  /// **'SAVE TEST RESULT'**
  String get saveTestResult;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @pickDropJumpVideo.
  ///
  /// In en, this message translates to:
  /// **'Pick a drop jump video to analyze'**
  String get pickDropJumpVideo;

  /// No description provided for @performanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Performance History'**
  String get performanceHistory;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @noJumpRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No jump records yet'**
  String get noJumpRecordsYet;

  /// No description provided for @deleteJump.
  ///
  /// In en, this message translates to:
  /// **'Delete Jump'**
  String get deleteJump;

  /// No description provided for @confirmDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Remove this {testType} record from {dateStr}?'**
  String confirmDeleteRecord(String testType, String dateStr);

  /// No description provided for @fatiguePercent.
  ///
  /// In en, this message translates to:
  /// **'{sign}{percent}% Fatigue'**
  String fatiguePercent(String sign, String percent);

  /// No description provided for @detailHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// No description provided for @detailFlightTime.
  ///
  /// In en, this message translates to:
  /// **'Flight Time'**
  String get detailFlightTime;

  /// No description provided for @detailFps.
  ///
  /// In en, this message translates to:
  /// **'FPS'**
  String get detailFps;

  /// No description provided for @detailRsiError.
  ///
  /// In en, this message translates to:
  /// **'RSI Error'**
  String get detailRsiError;

  /// No description provided for @detailErrorMargin.
  ///
  /// In en, this message translates to:
  /// **'Error Margin'**
  String get detailErrorMargin;

  /// No description provided for @detailContactTime.
  ///
  /// In en, this message translates to:
  /// **'Contact Time'**
  String get detailContactTime;

  /// No description provided for @detailRsiScore.
  ///
  /// In en, this message translates to:
  /// **'RSI Score'**
  String get detailRsiScore;

  /// No description provided for @detailBaselineAtTest.
  ///
  /// In en, this message translates to:
  /// **'Baseline at Test'**
  String get detailBaselineAtTest;

  /// No description provided for @selectAthleteToViewEvolution.
  ///
  /// In en, this message translates to:
  /// **'Select an athlete to view evolution'**
  String get selectAthleteToViewEvolution;

  /// No description provided for @evolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get evolution;

  /// No description provided for @needAtLeast2RsiTests.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 RSI tests to chart'**
  String get needAtLeast2RsiTests;

  /// No description provided for @recentTests.
  ///
  /// In en, this message translates to:
  /// **'Recent Tests'**
  String get recentTests;

  /// No description provided for @typeCmj.
  ///
  /// In en, this message translates to:
  /// **'CMJ'**
  String get typeCmj;

  /// No description provided for @typeFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get typeFatigue;

  /// No description provided for @typeRsi.
  ///
  /// In en, this message translates to:
  /// **'RSI'**
  String get typeRsi;

  /// No description provided for @addAthleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Athlete'**
  String get addAthleteTitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editAthlete.
  ///
  /// In en, this message translates to:
  /// **'Edit Athlete'**
  String get editAthlete;

  /// No description provided for @deleteAthlete.
  ///
  /// In en, this message translates to:
  /// **'Delete Athlete'**
  String get deleteAthlete;

  /// No description provided for @confirmDeleteAthlete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteAthlete(String name);

  /// No description provided for @testTagCmjBaseline.
  ///
  /// In en, this message translates to:
  /// **'CMJ BASELINE'**
  String get testTagCmjBaseline;

  /// No description provided for @testTagFatigue.
  ///
  /// In en, this message translates to:
  /// **'FATIGUE'**
  String get testTagFatigue;

  /// No description provided for @testTagRsi.
  ///
  /// In en, this message translates to:
  /// **'RSI'**
  String get testTagRsi;

  /// No description provided for @cmjAndFatigue.
  ///
  /// In en, this message translates to:
  /// **'CMJ & Fatigue'**
  String get cmjAndFatigue;

  /// No description provided for @markButtonLabeled.
  ///
  /// In en, this message translates to:
  /// **'{label} (#{frame})'**
  String markButtonLabeled(String label, int frame);

  /// No description provided for @navGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get navGroup;

  /// No description provided for @groupOverview.
  ///
  /// In en, this message translates to:
  /// **'Group Overview'**
  String get groupOverview;

  /// No description provided for @cmjHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'CMJ Height'**
  String get cmjHeightLabel;

  /// No description provided for @latestRsi.
  ///
  /// In en, this message translates to:
  /// **'RSI'**
  String get latestRsi;

  /// No description provided for @cmjImprovement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get cmjImprovement;

  /// No description provided for @relativePower.
  ///
  /// In en, this message translates to:
  /// **'Rel. Power'**
  String get relativePower;

  /// No description provided for @peakPower.
  ///
  /// In en, this message translates to:
  /// **'Peak Power'**
  String get peakPower;

  /// No description provided for @relativePowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Relative Power'**
  String get relativePowerLabel;

  /// No description provided for @bestRelativePower.
  ///
  /// In en, this message translates to:
  /// **'Best Rel. Power'**
  String get bestRelativePower;

  /// No description provided for @noAthletesInGroup.
  ///
  /// In en, this message translates to:
  /// **'No athletes in this group'**
  String get noAthletesInGroup;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noBaselineSet.
  ///
  /// In en, this message translates to:
  /// **'No baseline set'**
  String get noBaselineSet;

  /// No description provided for @baselineOutdated.
  ///
  /// In en, this message translates to:
  /// **'Update required ({days}d ago)'**
  String baselineOutdated(int days);

  /// No description provided for @baselineWithDate.
  ///
  /// In en, this message translates to:
  /// **'Baseline: {height} cm · {date}'**
  String baselineWithDate(String height, String date);

  /// No description provided for @pendingDailyTest.
  ///
  /// In en, this message translates to:
  /// **'Pending Daily Test'**
  String get pendingDailyTest;

  /// No description provided for @todayFatigueLoss.
  ///
  /// In en, this message translates to:
  /// **'Today: {loss}% · {status}'**
  String todayFatigueLoss(String loss, String status);

  /// No description provided for @fatigueOptimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get fatigueOptimal;

  /// No description provided for @fatigueModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get fatigueModerate;

  /// No description provided for @fatigueHigh.
  ///
  /// In en, this message translates to:
  /// **'High Fatigue'**
  String get fatigueHigh;

  /// No description provided for @rsiBaselineValue.
  ///
  /// In en, this message translates to:
  /// **'RSI: {score}'**
  String rsiBaselineValue(String score);

  /// No description provided for @contactTimeAxisMs.
  ///
  /// In en, this message translates to:
  /// **'Contact (ms)'**
  String get contactTimeAxisMs;

  /// No description provided for @flightTimeAxisMs.
  ///
  /// In en, this message translates to:
  /// **'Air Time (ms)'**
  String get flightTimeAxisMs;

  /// No description provided for @rsiScatterTitle.
  ///
  /// In en, this message translates to:
  /// **'RSI Scatter'**
  String get rsiScatterTitle;

  /// No description provided for @cmjBarChartTitle.
  ///
  /// In en, this message translates to:
  /// **'CMJ Bar Chart'**
  String get cmjBarChartTitle;

  /// No description provided for @fullscreenChart.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreenChart;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @allBaselinesSaved.
  ///
  /// In en, this message translates to:
  /// **'All baselines saved'**
  String get allBaselinesSaved;

  /// No description provided for @saveAthleteBaseline.
  ///
  /// In en, this message translates to:
  /// **'Save {name}\'s Baseline'**
  String saveAthleteBaseline(String name);

  /// No description provided for @athleteJumpProgress.
  ///
  /// In en, this message translates to:
  /// **'{name} ({done}/3)'**
  String athleteJumpProgress(String name, int done);

  /// No description provided for @pleaseSelectGroupFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a group with athletes first'**
  String get pleaseSelectGroupFirst;

  /// No description provided for @recordDropJumpNumber.
  ///
  /// In en, this message translates to:
  /// **'Record Drop Jump #{number}'**
  String recordDropJumpNumber(int number);

  /// No description provided for @saveAthleteRsi.
  ///
  /// In en, this message translates to:
  /// **'Save {name}\'s RSI'**
  String saveAthleteRsi(String name);

  /// No description provided for @allRsiTestsSaved.
  ///
  /// In en, this message translates to:
  /// **'All RSI tests saved'**
  String get allRsiTestsSaved;

  /// No description provided for @rsiTestInstructions.
  ///
  /// In en, this message translates to:
  /// **'Record up to 3 drop jumps to measure RSI performance.\nMaximum 3 jumps allowed.'**
  String get rsiTestInstructions;

  /// No description provided for @averageRsiScore.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE RSI SCORE'**
  String get averageRsiScore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
