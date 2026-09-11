(function exposeNextEvidenceUI(root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (root) root.NextEvidenceUI = api;
}(typeof window !== "undefined" ? window : globalThis, function buildNextEvidenceUI() {
  "use strict";

  const WORKSPACES = ["goal", "contract", "observation", "ledger"];

  function activeContract(state) {
    return state.contracts.findLast
      ? state.contracts.findLast((contract) => contract.status === "locked") || null
      : state.contracts.slice().reverse().find((contract) => contract.status === "locked") || null;
  }

  function latestObservation(state, contract) {
    if (!contract) return null;
    return state.observations
      .slice()
      .reverse()
      .find((observation) => observation.contractId === contract.id) || null;
  }

  function derivePrimaryWorkspace(state, options = {}) {
    if (options.recoveryPending) return "recovery";
    if (!state.goal) return "goal";
    if (state.goal.status === "exited") return "ledger";
    const contract = activeContract(state);
    if (!contract) return "contract";
    const latest = latestObservation(state, contract);
    if (options.revisionOpen || (latest && latest.decision === "revise")) return "contract";
    if (latest && latest.decision !== "keep") return "ledger";
    return "observation";
  }

  function workspaceAvailability(state) {
    const contract = activeContract(state);
    const hasAnyData = Boolean(state.goal || state.contracts.length || state.observations.length);
    return {
      goal: true,
      contract: Boolean(state.goal && state.goal.status === "active"),
      observation: Boolean(contract && state.goal && state.goal.status === "active"),
      ledger: hasAnyData,
    };
  }

  function referenceContract(state) {
    return activeContract(state) || state.contracts
      .slice()
      .sort((left, right) => right.version - left.version)[0] || null;
  }

  function ledgerRecords(state, scope = "current") {
    const records = state.observations.slice().reverse();
    if (scope === "all") return records;
    const reference = referenceContract(state);
    return reference
      ? records.filter((observation) => observation.contractId === reference.id)
      : [];
  }

  return {
    WORKSPACES,
    activeContract,
    derivePrimaryWorkspace,
    latestObservation,
    ledgerRecords,
    referenceContract,
    workspaceAvailability,
  };
}));
