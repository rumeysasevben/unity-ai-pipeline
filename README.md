# AI-driven Unity pipeline

How I build an online co-op Unity game with Claude Code doing the engineering and a system doing the verifying. I don't make builds or run tests by hand, and I direct Claude Code through written briefs rather than hand-writing code: every task is a written brief, every fix has a test, every build is one command.

The game (Double Trouble Delivery: Unity 6, URP, Mirror, Steam) is not public yet. This repo is the *system* around it, with game content removed.

| Real numbers from the game repo | |
|---|---|
| Time span | 2026-09-24 to 2026-11-12 (~7 weeks) |
| Commits | 635 (269 feat, 103 fix, 28 test) |
| Own C# | 620 files, ~117k lines, 23 assembly definitions |
| Automated tests | 1,277 (EditMode + PlayMode) |
| Written briefs / logged decisions | 24 / 331 |

## How it works

- **Briefs, not chat.** A brief states the goal, what must not be touched, how to commit and what "done" means. The agent decides without asking and records why in a numbered decision log. ([template](examples/brief-template.md))
- **Progress logs.** The agent writes timestamped status entries, so I read one page in the morning, not a transcript. ([real sample](examples/progress-log-sample.md))
- **Tests as the safety net.** No bug fix without a test that fails without it.
- **One-command pipelines.** Batch-mode builds with pre-build gates, a map-update script that runs play checks and exits non-zero on failure, and a packaging script. ([scripts](scripts/))

## Example: one overnight run (~80 min, one brief)

"Make everything online-ready, run the online tests, leave no bug." The agent audited all new features, found and fixed 5 online problems (each with a regression test), and produced two builds.

One of them: a minigame's world state was 1,234 bytes against a 1,015-byte packet limit, so clients silently received no state. Fix: split the state over two packets, bump the protocol (v34 to v35), and add a test that guards the byte budget on the real scene. Afterwards online PlayMode passed 36/36 and net EditMode 68/68.

## Design note

Game code talks to one `INetworkTransport` interface; Steam, Mirror KCP and a loopback transport sit behind it. Same pattern as a wrapper over several third-party SDKs. ([excerpt](examples/transport-interface.md))

## Limits

- The pipeline runs locally (Unity batch mode + shell/PowerShell), not on a hosted CI server. Moving it to GitHub Actions is the next step.
- Built for a PC/Steam game. I haven't used it for mobile SDK integration (ads, mediation, CMP) yet.
- Scripts are lightly edited from the real ones and meant to be read, not run as-is.
