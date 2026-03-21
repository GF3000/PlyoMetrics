// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get error => 'Error';

  @override
  String get newGroup => 'New Group';

  @override
  String get selectGroup => 'Select Group';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get tagPerformance => 'PERFORMANCE';

  @override
  String get cmjBaselineMeasurement => 'CMJ Baseline Measurement';

  @override
  String get verticalJumpMetricsFlightTime =>
      'Vertical jump metrics & flight time';

  @override
  String get pleaseSelectAthleteFirst => 'Please select an athlete first';

  @override
  String get tagMonitoring => 'MONITORING';

  @override
  String get readinessFatigueTest => 'Readiness / Fatigue Test';

  @override
  String get dailyCnsRecoveryTracking => 'Daily CNS & recovery tracking';

  @override
  String get completeCmjBaselineFirst => 'Complete a CMJ Baseline first';

  @override
  String get tagReactiveStrength => 'REACTIVE STRENGTH';

  @override
  String get rsiDropJumpTest => 'RSI Drop Jump Test';

  @override
  String get groundContactEfficiency => 'Ground contact & efficiency';

  @override
  String get selectAnAthleteFirst => 'Select an athlete first';

  @override
  String get athleteRoster => 'ATHLETE ROSTER';

  @override
  String get collapse => 'Collapse';

  @override
  String get viewAll => 'View All';

  @override
  String get errorLoadingAthletes => 'Error loading athletes';

  @override
  String get addAthlete => 'Add Athlete';

  @override
  String get navHome => 'Home';

  @override
  String get navEvolution => 'Evolution';

  @override
  String get navLog => 'Log';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileComingSoon => 'Profile coming soon!';

  @override
  String get renameGroup => 'Rename Group';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get groupName => 'Group Name';

  @override
  String confirmDeleteGroup(String groupName) {
    return 'Are you sure you want to delete \"$groupName\"?';
  }

  @override
  String get newMeasurement => 'New Measurement';

  @override
  String get cmjBaseline => 'CMJ Baseline';

  @override
  String get verticalJumpMetrics => 'Vertical jump metrics';

  @override
  String get fatigueTest => 'Fatigue Test';

  @override
  String get dailyReadinessTracking => 'Daily readiness tracking';

  @override
  String get rsiDropJump => 'RSI Drop Jump';

  @override
  String get cmjBaselineInstructions =>
      'Record at least 1 jump to establish a baseline.\nMaximum 3 jumps allowed.';

  @override
  String recordJumpNumber(int number) {
    return 'Record Jump #$number';
  }

  @override
  String get saveMeasurement => 'Save Measurement';

  @override
  String get incompleteBaseline => 'Incomplete Baseline';

  @override
  String get incompleteBaselineMessage =>
      'It is highly recommended to record at least 3 jumps to establish an accurate baseline and filter out anomalies. Are you sure you want to save?';

  @override
  String get saveAnyway => 'Save Anyway';

  @override
  String get noAthleteSelected => 'No athlete selected';

  @override
  String jumpNumber(int number) {
    return 'Jump #$number';
  }

  @override
  String get outlier => 'Outlier';

  @override
  String flightTimeInfo(String flightTime, String fps) {
    return 'Flight time: $flightTime ms  |  $fps FPS';
  }

  @override
  String get calculatedAverage => 'CALCULATED AVERAGE';

  @override
  String get outliersExcluded => 'Outliers excluded from average';

  @override
  String get selectJumpMoment => 'Select Jump Moment';

  @override
  String get pickVideoToAnalyze => 'Pick a video to analyze';

  @override
  String get analyzeJumpFromHere => 'Analyze Jump from Here';

  @override
  String get pickVideoFromGallery => 'Pick Video from Gallery';

  @override
  String get landingFrameAfterTakeoff =>
      'Landing frame must be after takeoff frame';

  @override
  String get framesInOrder =>
      'Frames must be in order: Landing 1 < Takeoff < Landing 2';

  @override
  String get frameAnalysis => 'Frame Analysis';

  @override
  String get extractingFrames => 'Extracting Frames';

  @override
  String processingVideoAtFps(String fps) {
    return 'Processing video at $fps FPS';
  }

  @override
  String get processingVideo => 'Processing video at ...';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get extractionFailed => 'Extraction Failed';

  @override
  String get goBack => 'Go Back';

  @override
  String get noFramesExtracted => 'No frames extracted';

  @override
  String frameCounter(int current, int total) {
    return 'Frame $current / $total';
  }

  @override
  String fpsDisplay(String fps) {
    return '$fps FPS';
  }

  @override
  String msDisplay(String time) {
    return '$time ms';
  }

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get landing1 => 'Landing 1';

  @override
  String get takeoff => 'Takeoff';

  @override
  String get landing2 => 'Landing 2';

  @override
  String get markTakeoff => 'Mark Takeoff';

  @override
  String get markLanding => 'Mark Landing';

  @override
  String get contact => 'Contact';

  @override
  String get flight => 'Flight';

  @override
  String get height => 'Height';

  @override
  String get rsi => 'RSI';

  @override
  String get flightTime => 'Flight Time';

  @override
  String get errorMarginLabel => 'Error';

  @override
  String get confirmJump => 'Confirm Jump';

  @override
  String get countermovementJumpCMJ => 'Countermovement Jump (CMJ)';

  @override
  String get currentJump => 'CURRENT JUMP';

  @override
  String get baselineMax => 'BASELINE MAX';

  @override
  String get fatigueStatus => 'Fatigue Status';

  @override
  String get optimal => 'Optimal';

  @override
  String get moderateFatigue => 'Moderate Fatigue';

  @override
  String get highFatigue => 'High Fatigue';

  @override
  String get fatigueOptimalMessage =>
      'Athlete is well recovered and ready for high-intensity training.';

  @override
  String get fatigueModerateMessage =>
      'Some fatigue detected. Consider moderate training loads.';

  @override
  String get fatigueHighMessage =>
      'Significant fatigue present. Recommend recovery or light activity.';

  @override
  String get baseline => 'Baseline';

  @override
  String get current => 'Current';

  @override
  String get recordDailyJump => 'Record Daily Jump';

  @override
  String get saveTest => 'Save Test';

  @override
  String get discardResult => 'Discard Result';

  @override
  String get newPersonalBest => 'New Personal Best!';

  @override
  String pbDialogMessage(String height) {
    return 'Your jump of ${height}cm exceeded the current baseline. Please redo the CMJ Baseline measurement to ensure accurate fatigue tracking.';
  }

  @override
  String get updateBaseline => 'Update Baseline';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get dropHeight => 'DROP HEIGHT';

  @override
  String heightCm(int height) {
    return '$height cm';
  }

  @override
  String get contactTime => 'CONTACT TIME';

  @override
  String get flightTimeCaps => 'FLIGHT TIME';

  @override
  String get reactiveStrengthIndex => 'REACTIVE STRENGTH INDEX';

  @override
  String rsiError(String delta) {
    return '± $delta error';
  }

  @override
  String get recordDropJump => 'Record Drop Jump';

  @override
  String get saveTestResult => 'SAVE TEST RESULT';

  @override
  String get discard => 'Discard';

  @override
  String get pickDropJumpVideo => 'Pick a drop jump video to analyze';

  @override
  String get performanceHistory => 'Performance History';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get noJumpRecordsYet => 'No jump records yet';

  @override
  String get deleteJump => 'Delete Jump';

  @override
  String confirmDeleteRecord(String testType, String dateStr) {
    return 'Remove this $testType record from $dateStr?';
  }

  @override
  String fatiguePercent(String sign, String percent) {
    return '$sign$percent% Fatigue';
  }

  @override
  String get detailHeight => 'Height';

  @override
  String get detailFlightTime => 'Flight Time';

  @override
  String get detailFps => 'FPS';

  @override
  String get detailRsiError => 'RSI Error';

  @override
  String get detailErrorMargin => 'Error Margin';

  @override
  String get detailContactTime => 'Contact Time';

  @override
  String get detailRsiScore => 'RSI Score';

  @override
  String get detailBaselineAtTest => 'Baseline at Test';

  @override
  String get selectAthleteToViewEvolution =>
      'Select an athlete to view evolution';

  @override
  String get evolution => 'Evolution';

  @override
  String get needAtLeast2RsiTests => 'Need at least 2 RSI tests to chart';

  @override
  String get recentTests => 'Recent Tests';

  @override
  String get typeCmj => 'CMJ';

  @override
  String get typeFatigue => 'Fatigue';

  @override
  String get typeRsi => 'RSI';

  @override
  String get addAthleteTitle => 'Add Athlete';

  @override
  String get name => 'Name';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get create => 'Create';

  @override
  String get editAthlete => 'Edit Athlete';

  @override
  String get deleteAthlete => 'Delete Athlete';

  @override
  String confirmDeleteAthlete(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get testTagCmjBaseline => 'CMJ BASELINE';

  @override
  String get testTagFatigue => 'FATIGUE';

  @override
  String get testTagRsi => 'RSI';

  @override
  String get cmjAndFatigue => 'CMJ & Fatigue';

  @override
  String markButtonLabeled(String label, int frame) {
    return '$label (#$frame)';
  }

  @override
  String get navGroup => 'Group';

  @override
  String get groupOverview => 'Group Overview';

  @override
  String get cmjHeightLabel => 'CMJ Height';

  @override
  String get latestRsi => 'RSI';

  @override
  String get cmjImprovement => 'Improvement';

  @override
  String get noAthletesInGroup => 'No athletes in this group';

  @override
  String get noDataAvailable => 'No data available';
}
