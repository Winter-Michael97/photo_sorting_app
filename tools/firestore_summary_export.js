/**
 * Firestore -> kompakte Ergebnis-Zusammenfassung
 *
 * Ausgabe:
 *   firestore_summary/results_summary.csv
 *
 * Eine Zeile = eine Versuchsperson.
 * Enthält die zusammengefassten Ergebnisse für SA, RA, SB und RB:
 * Foto-Set, Reihenfolge, Dauer, Trefferquote und Ratings.
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
const OUTPUT_FILE = path.join(OUTPUT_DIR, 'results_summary.csv');
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
      testerId: run.testerId || '',
      createdAt: toIso(run.createdAt),

      ageGroup: demographics.ageGroup || '',
      gender: demographics.gender || '',
      smartphoneOs: demographics.smartphoneOs || '',
      photoSortingFrequency: demographics.photoSortingFrequency || '',

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
      RB_comparison: RB.comparison,

      overallPreference: finalQ.overallPreference || '',
      independentPreference: finalQ.independentPreference || '',
      seriesPreference: finalQ.seriesPreference || '',
      perceivedSpeed: finalQ.perceivedSpeed || '',
      perceivedControl: finalQ.perceivedControl || '',
      perceivedEase: finalQ.perceivedEase || '',
      ownPhotoPreference: finalQ.ownPhotoPreference || '',
      comment: finalQ.comment || '',
    });
  }

  const columns = Object.keys(rows[0]);

  const lines = [
    columns.map(csvEscape).join(DELIMITER),
    ...rows.map((row) =>
      columns.map((column) => csvEscape(row[column])).join(DELIMITER)
    ),
  ];

  fs.writeFileSync(
    OUTPUT_FILE,
    '\uFEFF' + lines.join('\n'),
    'utf8'
  );

  console.log(`✓ ${OUTPUT_FILE}`);
  console.log(`✓ ${rows.length} Versuchsperson(en)`);
  console.log('');
  console.log('Erwartung pro vollständigem Datensatz:');
  console.log('  SA = 20 Entscheidungen');
  console.log('  RA = 20 Entscheidungen');
  console.log('  SB = 6 Entscheidungen');
  console.log('  RB = 6 Entscheidungen');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Export fehlgeschlagen:');
    console.error(error);
    process.exit(1);
  });
