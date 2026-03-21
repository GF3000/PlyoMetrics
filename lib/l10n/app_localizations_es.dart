// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get profile => 'Perfil';

  @override
  String get error => 'Error';

  @override
  String get newGroup => 'Nuevo Grupo';

  @override
  String get selectGroup => 'Seleccionar Grupo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String get tagPerformance => 'RENDIMIENTO';

  @override
  String get cmjBaselineMeasurement => 'Medición de Referencia CMJ';

  @override
  String get verticalJumpMetricsFlightTime =>
      'Métricas de salto vertical y tiempo de vuelo';

  @override
  String get pleaseSelectAthleteFirst =>
      'Por favor, selecciona un atleta primero';

  @override
  String get tagMonitoring => 'MONITOREO';

  @override
  String get readinessFatigueTest => 'Test de Preparación / Fatiga';

  @override
  String get dailyCnsRecoveryTracking =>
      'Seguimiento diario del SNC y recuperación';

  @override
  String get completeCmjBaselineFirst => 'Completa primero una Referencia CMJ';

  @override
  String get tagReactiveStrength => 'FUERZA REACTIVA';

  @override
  String get rsiDropJumpTest => 'Test de Salto en Caída RSI';

  @override
  String get groundContactEfficiency => 'Contacto con el suelo y eficiencia';

  @override
  String get selectAnAthleteFirst => 'Selecciona un atleta primero';

  @override
  String get athleteRoster => 'LISTA DE ATLETAS';

  @override
  String get collapse => 'Colapsar';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get errorLoadingAthletes => 'Error al cargar atletas';

  @override
  String get addAthlete => 'Agregar Atleta';

  @override
  String get navHome => 'Inicio';

  @override
  String get navEvolution => 'Evolución';

  @override
  String get navLog => 'Registro';

  @override
  String get navProfile => 'Perfil';

  @override
  String get profileComingSoon => '¡Perfil próximamente!';

  @override
  String get renameGroup => 'Renombrar Grupo';

  @override
  String get deleteGroup => 'Eliminar Grupo';

  @override
  String get groupName => 'Nombre del Grupo';

  @override
  String confirmDeleteGroup(String groupName) {
    return '¿Estás seguro de que deseas eliminar \"$groupName\"?';
  }

  @override
  String get newMeasurement => 'Nueva Medición';

  @override
  String get cmjBaseline => 'Salto CMJ';

  @override
  String get verticalJumpMetrics => 'Métricas de salto vertical';

  @override
  String get fatigueTest => 'Test de Fatiga';

  @override
  String get dailyReadinessTracking => 'Seguimiento diario de preparación';

  @override
  String get rsiDropJump => 'Salto en Caída RSI';

  @override
  String get cmjBaselineInstructions =>
      'Graba al menos 1 salto para establecer una referencia.\nMáximo 3 saltos permitidos.';

  @override
  String recordJumpNumber(int number) {
    return 'Grabar Salto #$number';
  }

  @override
  String get saveMeasurement => 'Guardar Medición';

  @override
  String get incompleteBaseline => 'Referencia Incompleta';

  @override
  String get incompleteBaselineMessage =>
      'Se recomienda grabar al menos 3 saltos para establecer una referencia precisa y filtrar anomalías. ¿Estás seguro de que deseas guardar?';

  @override
  String get saveAnyway => 'Guardar de Todos Modos';

  @override
  String get noAthleteSelected => 'Ningún atleta seleccionado';

  @override
  String jumpNumber(int number) {
    return 'Salto #$number';
  }

  @override
  String get outlier => 'Atípico';

  @override
  String flightTimeInfo(String flightTime, String fps) {
    return 'Tiempo de vuelo: $flightTime ms  |  $fps FPS';
  }

  @override
  String get calculatedAverage => 'PROMEDIO CALCULADO';

  @override
  String get outliersExcluded => 'Atípicos excluidos del promedio';

  @override
  String get selectJumpMoment => 'Seleccionar Momento del Salto';

  @override
  String get pickVideoToAnalyze => 'Selecciona un video para analizar';

  @override
  String get analyzeJumpFromHere => 'Analizar Salto desde Aquí';

  @override
  String get pickVideoFromGallery => 'Seleccionar Video de la Galería';

  @override
  String get landingFrameAfterTakeoff =>
      'El fotograma de aterrizaje debe ser posterior al de despegue';

  @override
  String get framesInOrder =>
      'Los fotogramas deben estar en orden: Aterrizaje 1 < Despegue < Aterrizaje 2';

  @override
  String get frameAnalysis => 'Análisis de Fotogramas';

  @override
  String get extractingFrames => 'Extrayendo Fotogramas';

  @override
  String processingVideoAtFps(String fps) {
    return 'Procesando video a $fps FPS';
  }

  @override
  String get processingVideo => 'Procesando video en ...';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get extractionFailed => 'Extracción Fallida';

  @override
  String get goBack => 'Volver';

  @override
  String get noFramesExtracted => 'No se extrajeron fotogramas';

  @override
  String frameCounter(int current, int total) {
    return 'Fotograma $current / $total';
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
  String get pause => 'Pausar';

  @override
  String get play => 'Reproducir';

  @override
  String get landing1 => 'Aterrizaje 1';

  @override
  String get takeoff => 'Despegue';

  @override
  String get landing2 => 'Aterrizaje 2';

  @override
  String get markTakeoff => 'Marcar Despegue';

  @override
  String get markLanding => 'Marcar Aterrizaje';

  @override
  String get contact => 'Contacto';

  @override
  String get flight => 'Vuelo';

  @override
  String get height => 'Altura';

  @override
  String get rsi => 'RSI';

  @override
  String get flightTime => 'Tiempo de Vuelo';

  @override
  String get errorMarginLabel => 'Error';

  @override
  String get confirmJump => 'Confirmar Salto';

  @override
  String get countermovementJumpCMJ => 'Salto con Contramovimiento (CMJ)';

  @override
  String get currentJump => 'SALTO ACTUAL';

  @override
  String get baselineMax => 'MÁXIMO DE REFERENCIA';

  @override
  String get fatigueStatus => 'Estado de Fatiga';

  @override
  String get optimal => 'Óptimo';

  @override
  String get moderateFatigue => 'Fatiga Moderada';

  @override
  String get highFatigue => 'Fatiga Alta';

  @override
  String get fatigueOptimalMessage =>
      'El atleta está bien recuperado y listo para entrenamiento de alta intensidad.';

  @override
  String get fatigueModerateMessage =>
      'Se detectó algo de fatiga. Considerar cargas de entrenamiento moderadas.';

  @override
  String get fatigueHighMessage =>
      'Fatiga significativa presente. Se recomienda recuperación o actividad ligera.';

  @override
  String get baseline => 'Referencia';

  @override
  String get current => 'Actual';

  @override
  String get recordDailyJump => 'Grabar Salto Diario';

  @override
  String get saveTest => 'Guardar Test';

  @override
  String get discardResult => 'Descartar Resultado';

  @override
  String get newPersonalBest => '¡Nuevo Récord Personal!';

  @override
  String pbDialogMessage(String height) {
    return 'Tu salto de ${height}cm superó la referencia actual. Por favor, rehaz la Medición de Referencia CMJ para asegurar un seguimiento preciso de la fatiga.';
  }

  @override
  String get updateBaseline => 'Actualizar Referencia';

  @override
  String get dismiss => 'Descartar';

  @override
  String get dropHeight => 'ALTURA DE CAÍDA';

  @override
  String heightCm(int height) {
    return '$height cm';
  }

  @override
  String get contactTime => 'TIEMPO DE CONTACTO';

  @override
  String get flightTimeCaps => 'TIEMPO DE VUELO';

  @override
  String get reactiveStrengthIndex => 'ÍNDICE DE FUERZA REACTIVA';

  @override
  String rsiError(String delta) {
    return '± $delta error';
  }

  @override
  String get recordDropJump => 'Grabar Salto en Caída';

  @override
  String get saveTestResult => 'GUARDAR RESULTADO';

  @override
  String get discard => 'Descartar';

  @override
  String get pickDropJumpVideo =>
      'Selecciona un video de salto en caída para analizar';

  @override
  String get performanceHistory => 'Historial de Rendimiento';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get noJumpRecordsYet => 'Sin registros de saltos aún';

  @override
  String get deleteJump => 'Eliminar Salto';

  @override
  String confirmDeleteRecord(String testType, String dateStr) {
    return '¿Eliminar este registro de $testType del $dateStr?';
  }

  @override
  String fatiguePercent(String sign, String percent) {
    return '$sign$percent% Fatiga';
  }

  @override
  String get detailHeight => 'Altura';

  @override
  String get detailFlightTime => 'Tiempo de Vuelo';

  @override
  String get detailFps => 'FPS';

  @override
  String get detailRsiError => 'Error RSI';

  @override
  String get detailErrorMargin => 'Margen de Error';

  @override
  String get detailContactTime => 'Tiempo de Contacto';

  @override
  String get detailRsiScore => 'Puntuación RSI';

  @override
  String get detailBaselineAtTest => 'Referencia en el Test';

  @override
  String get selectAthleteToViewEvolution =>
      'Selecciona un atleta para ver la evolución';

  @override
  String get evolution => 'Evolución';

  @override
  String get needAtLeast2RsiTests =>
      'Se necesitan al menos 2 tests RSI para graficar';

  @override
  String get recentTests => 'Tests Recientes';

  @override
  String get typeCmj => 'CMJ';

  @override
  String get typeFatigue => 'Fatiga';

  @override
  String get typeRsi => 'RSI';

  @override
  String get addAthleteTitle => 'Agregar Atleta';

  @override
  String get name => 'Nombre';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get create => 'Crear';

  @override
  String get editAthlete => 'Editar Atleta';

  @override
  String get deleteAthlete => 'Eliminar Atleta';

  @override
  String confirmDeleteAthlete(String name) {
    return '¿Estás seguro de que deseas eliminar a $name?';
  }

  @override
  String get testTagCmjBaseline => 'REFERENCIA CMJ';

  @override
  String get testTagFatigue => 'FATIGA';

  @override
  String get testTagRsi => 'RSI';

  @override
  String get cmjAndFatigue => 'CMJ y Fatiga';

  @override
  String markButtonLabeled(String label, int frame) {
    return '$label (#$frame)';
  }

  @override
  String get navGroup => 'Grupo';

  @override
  String get groupOverview => 'Vista del Grupo';

  @override
  String get cmjHeightLabel => 'Altura CMJ';

  @override
  String get latestRsi => 'RSI';

  @override
  String get cmjImprovement => 'Mejora';

  @override
  String get noAthletesInGroup => 'No hay atletas en este grupo';

  @override
  String get noDataAvailable => 'Sin datos disponibles';

  @override
  String get noBaselineSet => 'Sin línea base';

  @override
  String baselineOutdated(int days) {
    return 'Actualización requerida (hace ${days}d)';
  }

  @override
  String baselineWithDate(String height, String date) {
    return 'Línea base: $height cm · $date';
  }

  @override
  String get pendingDailyTest => 'Test diario pendiente';

  @override
  String todayFatigueLoss(String loss, String status) {
    return 'Hoy: $loss% · $status';
  }

  @override
  String get fatigueOptimal => 'Óptimo';

  @override
  String get fatigueModerate => 'Moderado';

  @override
  String get fatigueHigh => 'Fatiga alta';

  @override
  String rsiBaselineValue(String score) {
    return 'RSI: $score';
  }

  @override
  String get contactTimeAxisMs => 'Contacto (ms)';

  @override
  String get flightTimeAxisMs => 'T. Vuelo (ms)';

  @override
  String get rsiScatterTitle => 'Dispersión RSI';

  @override
  String get fullscreenChart => 'Pantalla completa';
}
