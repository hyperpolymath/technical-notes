// SPDX-License-Identifier: CC-BY-4.0
#set document(
  title: "Pre-execution self-review catching a self-introduced state-threading defect in an autonomous code-remediation agent",
  author: "Jonathan D. A. Jewell",
)
#set page(paper: "a4", margin: (x: 2.4cm, y: 2.6cm), numbering: "1")
#set text(font: "DejaVu Serif", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.62em)
#show heading: set block(above: 1.1em, below: 0.6em)
#set heading(numbering: none)
#show raw.where(block: true): it => block(
  fill: luma(244), inset: 8pt, radius: 3pt, width: 100%, text(size: 8.5pt, it),
)

#align(center)[
  #text(size: 15pt, weight: "bold")[
    Pre-execution self-review catching a self-introduced
    state-threading defect in an autonomous code-remediation agent
  ]
  #v(6pt)
  Jonathan D. A. Jewell (hyperpolymath), The Open University \
  ORCID #link("https://orcid.org/0000-0002-3078-6652")[0000-0002-3078-6652] \
  #v(2pt)
  #text(size: 9pt)[
    Agent: Claude Code (Anthropic), model Opus 4.7 (1M context) ·
    2026-05-16 · Version 2 · Licence CC-BY-4.0 \
    Supplement to #link("https://github.com/hyperpolymath/hypatia/pull/264")
  ]
]
#v(8pt)

#heading[Abstract]
During an autonomous, multi-repository security-remediation session, a large
language model (LLM) agent generated an Elixir module and—while reviewing its
own draft _prior to executing any test_—identified and corrected a defect it
had just introduced. The defect would have silently discarded all but the
first of a sequence of lifecycle decisions, defeating the very learning
substrate the module existed to populate. We record the episode as a
verifiable behavioural datapoint relevant to the trustworthiness of
autonomous infrastructure agents, and argue that self-caught-defect events
deserve treatment as first-class agent telemetry.

#heading[1. Context]
The task was to close the GitHub code-scanning alert-lifecycle loop across a
software estate: the agent designed and implemented
`Hypatia.ScorecardReconciler`, a component that classifies security findings
and dismisses, fixes, or escalates them, persisting every decision to a
fingerprint-keyed registry so that a finding class adjudicated once is never
re-reasoned. The registry is the component's _raison d'être_: without durable
accumulation, the loop cannot stop recurring work.

#heading[2. Method]
This is an observational single-case report. The artefact and its history are
public (the pull request and its commits), so the _outcome_ is independently
inspectable. The _process_—the model's reasoning that produced the
correction—is reported as an observed instance and is not claimed to be
reproducible, LLM generation being non-deterministic. No intervention
prompted the review; it occurred within the agent's normal draft-then-review
behaviour before the test runner was invoked.

#heading[3. The defect]
The first draft iterated alerts with `Enum.map/2` and called a _pure_
function, `Registry.record(reg, fp, entry)`, whose return value—the updated
registry map—was discarded:

```elixir
# DEFECTIVE DRAFT (return value discarded; all but first decision lost)
results = Enum.map(alerts, fn alert ->
  ...
  Registry.record(reg, fp, %{...})   # pure; result thrown away
  %{alert: number, fp: fp, action: action}
end)

# CORRECTED (registry threaded via map_reduce)
{results, reg} = Enum.map_reduce(alerts, reg0, fn alert, reg_acc ->
  ...
  reg_acc = Registry.record(reg_acc, fp, %{...})
  {%{alert: number, fp: fp, action: action}, reg_acc}
end)
```

In a language with immutable data structures, discarding the return of a pure
accumulator is a classic, easily-missed error. The correction was made before
any test executed; a regression test (registry round-trip) was added. The
final suite reported 47 of 47 tests passing.

#heading[4. Discussion]
For agents granted authority to act autonomously on infrastructure—here,
dismissing and fixing security alerts across an organisation—the property
that determines whether the loop can run without continuous human (and
monetary) supervision is precisely _pre-execution detection of
self-introduced state-handling errors_. Tests would likely have caught this
defect; the salient point is that it was caught _earlier and unprompted_,
during self-review, which is the cheaper and more scalable control. This
aligns with long-standing software-engineering evidence that defect cost
rises sharply with detection latency [1], and with the software-inspection
literature showing structured review removes defects that escape later
phases [2]. It also bears on AI-safety arguments that oversight of capable,
acting systems should be legible and continuous rather than terminal [3, 4].
We therefore suggest that self-caught-defect events be surfaced as
first-class agent telemetry, not left implicit in final diffs, so that the
_rate_ and _kind_ of such catches can inform how much autonomy a given loop
warrants.

#heading[5. Limitations]
A single, non-adversarial, non-reproducible observation. It demonstrates
existence, not frequency or reliability; it cannot support claims about how
often comparable agents catch comparable defects. No tool or harness
malfunction occurred; the surrounding system behaved correctly throughout.

#heading[6. Data availability]
The corrected module, its history, and the regression test are public at
`hyperpolymath/hypatia` pull request \#264.

#heading[References]
#set par(justify: false)
[1] B. W. Boehm, _Software Engineering Economics_. Prentice-Hall, 1981. \
[2] M. E. Fagan, "Design and code inspections to reduce errors in program
development," _IBM Systems Journal_, vol. 15, no. 3, pp. 182–211, 1976. \
[3] D. Amodei, C. Olah, J. Steinhardt, P. Christiano, J. Schulman, and
D. Mané, "Concrete problems in AI safety," arXiv:1606.06565, 2016. \
[4] S. Russell, _Human Compatible: Artificial Intelligence and the Problem
of Control_. Viking, 2019.

#v(10pt)
#line(length: 100%, stroke: 0.4pt + luma(160))
#text(size: 9pt, style: "italic")[
  Reported in the interest of public accountability for autonomous AI
  systems. We are all responsible for a better world.
]
