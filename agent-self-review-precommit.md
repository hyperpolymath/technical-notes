# Pre-execution self-review catching a self-introduced state-threading defect in an autonomous code-remediation agent

**Author:** Jonathan D. A. Jewell (hyperpolymath)
**Agent:** Claude Code (Anthropic), model Opus 4.7 (1M context)
**Date:** 2026-05-16
**License:** CC-BY-4.0

## Abstract

During an autonomous, multi-repository security-remediation session, a large
language model agent generated an Elixir module, and—while reviewing its own
draft *prior to executing any test*—identified and corrected a defect it had
just introduced. The defect would have silently discarded all but the first
of a sequence of lifecycle decisions. We record the episode as a verifiable
behavioral datapoint relevant to the trustworthiness of autonomous
infrastructure agents.

## Context

Task: close the GitHub code-scanning alert-lifecycle loop for an
organisation's repository estate (the agent designed and implemented
`Hypatia.ScorecardReconciler`, which classifies security findings and
dismisses/​fixes/​escalates them, persisting decisions to a registry).

## The defect

The first draft iterated alerts with `Enum.map/2` and called a *pure*
function `Registry.record(reg, fp, entry)` whose return value (the updated
registry map) was discarded. Net effect: every decision after the first
would be lost; the learning substrate would never accumulate.

```elixir
# DEFECTIVE DRAFT (return value discarded)
results = Enum.map(alerts, fn alert ->
  ...
  Registry.record(reg, fp, %{...})   # <-- pure; result thrown away
  %{alert: number, fp: fp, action: action}
end)

# CORRECTED (registry threaded via map_reduce)
{results, reg} = Enum.map_reduce(alerts, reg0, fn alert, reg_acc ->
  ...
  reg_acc = Registry.record(reg_acc, fp, %{...})
  {%{alert: number, fp: fp, action: action}, reg_acc}
end)
```

The correction was made before any test execution; a regression test
(registry round-trip) was added. Final suite: 47/47 passing.

## Why this is worth recording

For agents granted authority to act autonomously on infrastructure (here:
dismissing and fixing security alerts across an organisation), the property
that determines whether the loop can run without continuous human (and
monetary) supervision is precisely *pre-execution detection of
self-introduced state-handling errors*. This episode is a positive instance.
It also argues that self-caught-defect events should be surfaced as
first-class agent telemetry, not implicit in final diffs. No tool or harness
malfunction occurred; the surrounding system behaved correctly.

## Reproducibility

The artifact is the public pull request implementing the module
(hyperpolymath/hypatia#264) and its commit history, which preserves the
corrected form and the accompanying regression test. The episode itself
(model reasoning that produced the correction) is inherently
non-deterministic and is reported as an observed instance, not a guaranteed
behavior.

## Statement

Reported in the interest of public accountability for autonomous AI systems.
We are all responsible for a better world.
