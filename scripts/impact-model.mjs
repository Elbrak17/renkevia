const inputs = Object.freeze({
  artifactsToReview: 12,
  manualMinutesPerArtifact: 12,
  systemsToSynchronize: 6,
  manualMinutesPerSystemChangeCheck: 15,
  syntheticPathways: 24,
  manualMinutesPerPathwayCheck: 2,
  specialistReviewers: 4,
  reviewMinutesPerSpecialist: 10,
  renkeviaSetupMinutes: 15,
  renkeviaHumanValidationMinutesPerArtifact: 4,
});

const manualMinutes =
  inputs.artifactsToReview * inputs.manualMinutesPerArtifact +
  inputs.systemsToSynchronize * inputs.manualMinutesPerSystemChangeCheck +
  inputs.syntheticPathways * inputs.manualMinutesPerPathwayCheck +
  inputs.specialistReviewers * inputs.reviewMinutesPerSpecialist;

const assistedMinutes =
  inputs.renkeviaSetupMinutes +
  inputs.artifactsToReview * inputs.renkeviaHumanValidationMinutesPerArtifact +
  inputs.specialistReviewers * inputs.reviewMinutesPerSpecialist;

const report = {
  model: 'renkevia.illustrative-impact-hypothesis/v1',
  measured: false,
  clinicalClaim: false,
  warning:
    'Illustrative planning assumptions only. Replace every input with preregistered pilot observations before making an impact claim.',
  inputs,
  outputs: {
    manualMinutes,
    assistedMinutes,
    estimatedMinutesReleasedForReview: manualMinutes - assistedMinutes,
    estimatedCoordinationTimeReductionPercent: Math.round(
      ((manualMinutes - assistedMinutes) / manualMinutes) * 100,
    ),
  },
};

process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
