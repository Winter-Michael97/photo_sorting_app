/**
 * Firestore -> kompakte Ergebnis-Zusammenfassung
 *
 * Ausgabe:
 *   firestore_summary/results_summary.csv
 *   firestore_summary/interaction_events.csv
 *
 * results_summary.csv:
 *   Eine Zeile = eine Versuchsperson.
 *   Enthält die zusammengefassten Ergebnisse für SA, RA, SB und RB:
 *   Foto-Set, Reihenfolge, Dauer, Trefferquote, Ratings,
 *   Gerät, Demografie und Abschlussfragebogen.
 *
 * interaction_events.csv:
 *   Eine Zeile = ein geloggtes Präsentations-/Interaktionsereignis.
 *   Enthält u. a. Foto-ID, Serie, Schwierigkeit, Zeitstempel,
 *   Position, Swipe-/Raster-Aktion und gemessene Dauer.
 *
 * WICHTIG:
 * Die Ground Truth wird NICHT nochmal hart im Script definiert.
 * Die App hat sie bereits beim Speichern in `isCorrect` umgesetzt.
 * Dadurch kann die CSV nicht versehentlich von der Dart-Ground-Truth abweichen.
 *
 * Installation:
 *   npm init -y
 *   npm install firebase-admin
 *
 * Start:
 *   node export_firestore_summary.js "C:\Pfad\zu\serviceAccountKey.json"
 */

const fs = require('fs');
const path = require('path');
const { initializeApp, cert, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccountPath = process.argv[2];

if (serviceAccountPath) {
  const resolved = path.resolve(serviceAccountPath);

  if (!fs.existsSync(resolved)) {
    console.error(`Service-Account-Datei nicht gefunden: ${resolved}`);
    process.exit(1);
  }

  const serviceAccount = JSON.parse(fs.readFileSync(resolved, 'utf8'));

  initializeApp({
    credential: cert(serviceAccount),
  });
} else {
  initializeApp({
    credential: applicationDefault(),
  });
}

const db = getFirestore();

const OUTPUT_DIR = path.join(process.cwd(), 'firestore_summary');
const SUMMARY_FILE = path.join(OUTPUT_DIR, 'results_summary.csv');
const INTERACTION_FILE = path.join(OUTPUT_DIR, 'interaction_events.csv');
const DELIMITER = ';';

fs.mkdirSync(OUTPUT_DIR, { recursive: true });

function csvEscape(value) {
  if (value === null || value === undefined) return '';

  const text = String(value).replace(/\r?\n/g, ' ');

  if (text.includes('"') || text.includes(DELIMITER) || text.includes('\n')) {
    return `"${text.replace(/"/g, '""')}"`;
  }

  return text;
}

function writeCsv(filePath, rows) {
  if (!rows.length) {
    fs.writeFileSync(filePath, '\uFEFF', 'utf8');
    return;
  }

  const columns = Object.keys(rows[0]);

  const lines = [
    columns.map(csvEscape).join(DELIMITER),
    ...rows.map((row) =>
      columns.map((column) => csvEscape(row[column])).join(DELIMITER)
    ),
  ];

  fs.writeFileSync(
    filePath,
    '\uFEFF' + lines.join('\n'),
    'utf8'
  );
}

function toIso(value) {
  if (!value) return '';

  if (typeof value.toDate === 'function') {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (typeof value === 'string') {
    return value;
  }

  if (value._seconds !== undefined) {
    return new Date(value._seconds * 1000).toISOString();
  }

  return String(value);
}

function participantNumber(id) {
  const match = String(id || '').match(/\d+/);
  return match ? Number(match[0]) : Number.MAX_SAFE_INTEGER;
}

function round(value, digits = 2) {
  if (value === null || value === undefined || Number.isNaN(value)) return '';
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function findCondition(run, conditionId) {
  return (run.conditionOrder || []).find(
    (condition) => condition.conditionId === conditionId
  );
}

function findTiming(run, conditionId) {
  return (run.conditionTimings || []).find(
    (timing) => timing.conditionId === conditionId
  );
}

function ratingsFor(run, conditionId) {
  const result = {};

  for (const rating of run.ratings || []) {
    if (rating.conditionId === conditionId) {
      result[rating.questionId] = rating.rating;
    }
  }

  return result;
}

function decisionsFor(run, conditionId) {
  return (run.decisions || []).filter(
    (decision) => decision.conditionId === conditionId
  );
}

function summarizeCondition(run, conditionId) {
  const condition = findCondition(run, conditionId) || {};
  const timing = findTiming(run, conditionId) || {};
  const ratings = ratingsFor(run, conditionId);
  const decisions = decisionsFor(run, conditionId);

  const evaluated = decisions.filter(
    (decision) => typeof decision.isCorrect === 'boolean'
  );

  const correctCount = evaluated.filter(
    (decision) => decision.isCorrect === true
  ).length;

  const accuracy =
    evaluated.length > 0 ? (correctCount / evaluated.length) * 100 : null;

  const conditionPosition =
    (run.conditionOrder || []).findIndex(
      (entry) => entry.conditionId === conditionId
    ) + 1;

  return {
    photoSet: condition.photoSetId || '',
    position: conditionPosition > 0 ? conditionPosition : '',
    durationSec:
      typeof timing.durationMs === 'number'
        ? round(timing.durationMs / 1000, 3)
        : '',
    decisions: decisions.length,
    correct: correctCount,
    accuracyPercent: accuracy === null ? '' : round(accuracy, 2),

    ease: ratings.ease ?? '',
    control: ratings.control ?? '',
    confidence: ratings.confidence ?? '',
    workload: ratings.workload ?? '',
    satisfaction: ratings.satisfaction ?? '',
    playfulness: ratings.playfulness ?? '',
    comparison: ratings.comparison ?? '',
  };
}

async function main() {
  console.log('Lade study_runs aus Firestore ...');

  const snapshot = await db.collection('study_runs').get();

  if (snapshot.empty) {
    console.log('Keine Studienläufe gefunden.');
    return;
  }

  const runs = snapshot.docs.map((doc) => ({
    firestoreDocId: doc.id,
    ...doc.data(),
  }));

  runs.sort(
    (a, b) =>
      participantNumber(a.participantId) -
      participantNumber(b.participantId)
  );

  const rows = [];

  for (const run of runs) {
    const SA = summarizeCondition(run, 'SA');
    const RA = summarizeCondition(run, 'RA');
    const SB = summarizeCondition(run, 'SB');
    const RB = summarizeCondition(run, 'RB');

    const demographics = run.demographics || {};
    const finalQ = run.finalQuestionnaire || {};

    rows.push({
      participantId: run.participantId || '',
      counterbalanceGroup: run.counterbalanceGroup ?? '',
      deviceId: run.deviceId || '',
      deviceModel: run.deviceModel || '',
      testerId: run.testerId || '',
      createdAt: toIso(run.createdAt),

      // Neue Version: exaktes Alter.
      // ageGroup bleibt zusätzlich drin, damit ältere Testläufe weiterhin
      // ohne Informationsverlust exportiert werden können.
      age: demographics.age ?? '',
      ageNotProvided: demographics.ageNotProvided ?? '',
      ageGroup: demographics.ageGroup ?? '',
      gender: demographics.gender ?? '',
      smartphoneOs: demographics.smartphoneOs ?? '',
      photoSortingFrequency: demographics.photoSortingFrequency ?? '',

      SA_photoSet: SA.photoSet,
      SA_position: SA.position,
      SA_durationSec: SA.durationSec,
      SA_decisions: SA.decisions,
      SA_correct: SA.correct,
      SA_accuracyPercent: SA.accuracyPercent,
      SA_ease: SA.ease,
      SA_control: SA.control,
      SA_confidence: SA.confidence,
      SA_workload: SA.workload,
      SA_satisfaction: SA.satisfaction,
      SA_playfulness: SA.playfulness,

      RA_photoSet: RA.photoSet,
      RA_position: RA.position,
      RA_durationSec: RA.durationSec,
      RA_decisions: RA.decisions,
      RA_correct: RA.correct,
      RA_accuracyPercent: RA.accuracyPercent,
      RA_ease: RA.ease,
      RA_control: RA.control,
      RA_confidence: RA.confidence,
      RA_workload: RA.workload,
      RA_satisfaction: RA.satisfaction,
      RA_playfulness: RA.playfulness,

      SB_photoSet: SB.photoSet,
      SB_position: SB.position,
      SB_durationSec: SB.durationSec,
      SB_decisions: SB.decisions,
      SB_correct: SB.correct,
      SB_accuracyPercent: SB.accuracyPercent,
      SB_ease: SB.ease,
      SB_control: SB.control,
      SB_confidence: SB.confidence,
      SB_workload: SB.workload,
      SB_satisfaction: SB.satisfaction,
      SB_playfulness: SB.playfulness,
      SB_comparison: SB.comparison,

      RB_photoSet: RB.photoSet,
      RB_position: RB.position,
      RB_durationSec: RB.durationSec,
      RB_decisions: RB.decisions,
      RB_correct: RB.correct,
      RB_accuracyPercent: RB.accuracyPercent,
      RB_ease: RB.ease,
      RB_control: RB.control,
      RB_confidence: RB.confidence,
      RB_workload: RB.workload,
      RB_satisfaction: RB.satisfaction,
      RB_playfulness: RB.playfulness,
      RB_comparison: RB.comparison,

      // Bipolare Skala: -3 = Swipe, 0 = neutral, +3 = Raster.
      // WICHTIG: ?? statt ||, damit der gültige Wert 0 nicht verloren geht.
      overallPreference: finalQ.overallPreference ?? '',
      independentPreference: finalQ.independentPreference ?? '',
      seriesPreference: finalQ.seriesPreference ?? '',
      perceivedSpeed: finalQ.perceivedSpeed ?? '',
      perceivedControl: finalQ.perceivedControl ?? '',
      perceivedEase: finalQ.perceivedEase ?? '',
      ownPhotoPreference: finalQ.ownPhotoPreference ?? '',

      preferenceScaleMin: finalQ.scaleMin ?? '',
      preferenceScaleMax: finalQ.scaleMax ?? '',
      preferenceScaleLeft: finalQ.scaleLeft ?? '',
      preferenceScaleCenter: finalQ.scaleCenter ?? '',
      preferenceScaleRight: finalQ.scaleRight ?? '',

      interactionEventCount: (run.interactionEvents || []).length,
      comment: finalQ.comment ?? '',
    });
  }

  writeCsv(SUMMARY_FILE, rows);

  // Detaillierter Export aller Präsentations-/Interaktionsereignisse.
  // Damit bleiben Einzelbildzeiten und das tatsächliche Auftauchen der Bilder
  // für die spätere Analyse erhalten.
  const interactionRows = [];

  for (const run of runs) {
    const events = [...(run.interactionEvents || [])].sort(
      (a, b) => (a.sequence ?? 0) - (b.sequence ?? 0)
    );

    for (const event of events) {
      interactionRows.push({
        participantId: run.participantId || '',
        counterbalanceGroup: run.counterbalanceGroup ?? '',
        deviceId: run.deviceId || '',
        deviceModel: run.deviceModel || '',

        sequence: event.sequence ?? '',
        timestamp: toIso(event.timestamp),

        conditionId: event.conditionId ?? '',
        interfaceType: event.interfaceType ?? '',
        taskType: event.taskType ?? '',
        eventType: event.eventType ?? '',

        photoId: event.photoId ?? '',
        seriesId: event.seriesId ?? '',
        difficulty: event.difficulty ?? '',

        presentationIndex: event.presentationIndex ?? '',
        seriesIndex: event.seriesIndex ?? '',
        roundNumber: event.roundNumber ?? '',
        positionInRound: event.positionInRound ?? '',
        gridPosition: event.gridPosition ?? '',

        action: event.action ?? '',
        previousAction: event.previousAction ?? '',
        previousPhotoId: event.previousPhotoId ?? '',

        durationMs: event.durationMs ?? '',
        durationSec:
          typeof event.durationMs === 'number'
            ? round(event.durationMs / 1000, 3)
            : '',

        visibleDurationMs: event.visibleDurationMs ?? '',
        visibleDurationSec:
          typeof event.visibleDurationMs === 'number'
            ? round(event.visibleDurationMs / 1000, 3)
            : '',

        expectedAction: event.expectedAction ?? '',
        isBestInSeries: event.isBestInSeries ?? '',
      });
    }
  }

  writeCsv(INTERACTION_FILE, interactionRows);

  console.log(`✓ ${SUMMARY_FILE}`);
  console.log(`✓ ${INTERACTION_FILE}`);
  console.log(`✓ ${rows.length} Versuchsperson(en)`);
  console.log(`✓ ${interactionRows.length} Interaktionsereignis(se)`);
  console.log('');
  console.log('Erwartung pro vollständigem Datensatz:');
  console.log('  SA = 20 Entscheidungen');
  console.log('  RA = 20 Entscheidungen');
  console.log('  SB = 8 Serienentscheidungen (4 Easy + 4 Hard)');
  console.log('  RB = 8 Serienentscheidungen (4 Easy + 4 Hard)');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Export fehlgeschlagen:');
    console.error(error);
    process.exit(1);
  });
