# Brief template

A condensed, game-neutral version of the briefs I give Claude Code (the real ones are 24 files of ~100 lines each). A brief is pasted into a fresh session; the agent reads it, works alone, and reports in a progress file.

The point of the format: **the agent never has to ask me anything**, and a human can verify the result in minutes.

---

```
You are working on "<game>" (CLAUDE.md in the repo root). Read CLAUDE.md first, then docs/plan/CURRENT_PHASE.md,
the last 15 rows of docs/decisions.md (continue the numbering after the last one), and the docs named below.
Code, comments and commit messages are in English; report to me in <my language>.

BRANCH: work on `feature/<name>` or a child branch. NEVER push (I say so when I want that).
Commit each part on its own with explicit `git add <paths>` (never `git add -A`).
DO NOT TOUCH: <list of files and folders that belong to someone else, e.g. art owned by the artist, generated files>.

WHAT I ASKED FOR (my words, then what they mean)
A. "<my request, quoted>"
   -> <the agent's reading of it: scope, where it lives in the code, what "done" looks like>
B. ...

STANDING ORDERS
- NO QUESTIONS. Pick the best option, record the reason as a numbered entry in docs/decisions.md, keep going.
- ORDER OF WORK: lowest risk first, the builds last, from a clean state after every test is green.
- If something blocks a part for more than ~40 minutes: make the safest working version, note it, move on.
- BUGS: after each part run its targeted tests (by CLASS NAME) and a play-through probe on the real scene.
  A bug found = fixed AND a test that would have caught it, or a clear explanation why it is not testable.
  Do not run the whole suite; run the classes of every file you changed plus the ones listed in the brief.
- UNITY CONTROL: check whether the Editor is open before a batch run. Never close anything of mine.
  Run long jobs in the background. If a run seems frozen (no log growth for 10 minutes), read the Editor log,
  kill only the process you started, and rerun.
- REPORTS: every 60 minutes append a short, timestamped status to docs/prompts/<name>-progress.md
  (what is done, what is running, what is next, any problem).
- FINAL REPORT (short): per part what changed, what was verified and how, what is NOT verified,
  and the SINGLE next step for me.
- DOCS: update CURRENT_PHASE.md, decisions.md and the progress file.
```

---

## Why each section exists

| Section | Problem it prevents |
|---|---|
| Read-first list + last decisions | A fresh session has no memory; the decision log is the memory |
| `DO NOT TOUCH` list | The agent "fixing" files other people own, or generated files |
| My words quoted, then the meaning | Misreading a short request; I can check the reading before it runs |
| No questions + decision log | Overnight runs stalling on a question nobody answers; still leaves an audit trail |
| Risk order, builds last | A broken build step hiding a good fix |
| "A fix needs a test that fails without it" | Silent regressions and untestable "fixes" |
| Targeted tests by class name | Hours-long full runs, and capture tests that leak scenes |
| Unity control rules | Fighting me for the project lock; killing the wrong process |
| Timestamped progress file | Reading a transcript in the morning instead of one page |
| "What is NOT verified" in the final report | Overstated results |
