# Online test prep: progress (2026-11-06)

Branch `feature/p9-online-prep` (child of `feature/p9-feel-fixes`), not pushed. Brief: `docs/prompts/online-test-prep.md`.

## 02:36 start
- No Editor holds the project (only Unity Hub's `unity.exe serve`): batch runs are allowed.

## 02:50 G done (0b057ac2, decision #256)
- Grey burst after the wipe: the lens view's pale wet film covered the whole view for 1.5 s after each stroke. Removed. `LensWipeTests` (map 02, rain): veil 0.000 in the 2 s after a stroke (was 0.09); drops come back. FeelPart7Tests and DuskSceneTests pass.
- The evening: driven by the round clock (host's online) as before; darker at the end (sun 1.00 -> 0.25 over the shift). DuskClockTests (new test) pass.

## 03:05 status (E, F, A done)
- E (03d383fb, #257): How To Play is a 2D screen of five pages in the Settings look; HowToPlayScreenTests (found and fixed: a page set while another tab was selected jumped back the next frame).
- F (55f64820, #258): the title camera circled the sea (its bounds included the 4.5 km sea mesh); now it circles the town. Map under the title in 0.55-0.73 s (Editor), 22 of 25 view rays on the town; game and back leave one map (MenuLifeTests).
- A (bb4c1fc6, #259): Drive has nothing newer than Art/Lobby (16 files, same sizes). Lobby built from the artist's pieces like lobi4.png; DepotLobbyTests pass.
- Next: B and C (online audit, tests, newcomer path, how-to doc), then D (builds).

## 03:40 status (B and C in code)
- Online audit found and fixed (each with a test that fails without the fix):
  - #260 the town clutter was stepped twice by a client's re-run (OnlineClutterReplayTests).
  - #261 online the host's "tutorial learned" hid the tutorial from a new friend (OnlineDeliveryTests tutorial test, TutorialRulesTests).
  - #262 on the REAL map 02 scene the trash basketball's world state (1234 bytes) and the barrel wall's (about 1183) did not fit a packet (1015): the client got no state during them; the minigame block overflowed its 400 bytes and threw. Now such a state goes in two packets; block 700. Protocol 34 -> 35. Map02WorldStateBudgetTests.
  - #263 the Online Test Build and the lobby's Start were still the OLD map (and lacked map 02 for the title). BuildScenesTests.
  - #264 newcomer texts in The Depot, the partner-left box, docs/online-test-howto.md.
- Online PlayMode 36/36, net EditMode 68/68 green after the fixes.
- Next: a two-process KCP smoke if it can be automated, then the two builds (D).

## 03:58 D done: the two builds
- Direct3D 11 only: ProjectSettings `m_BuildTargetGraphicsAPIs` Windows `m_APIs: 02000000` (Direct3D11), Auto off; both players' logs say "Direct3D 11.0 [level 11.1]" (Unity still copies D3D12\D3D12Core.dll, unused).
- Online: `Builds/Online_2026-11-06_0339` -> `Builds/MyGame_Online_2026-11-06.zip` (412 MB; protocol 35, steam_appid.txt 480, map 02). Unpacked and started: title with map 02 behind it in 0.55 s, no errors.
- Local (one keyboard, no Steam, no Online word on the title): `Builds/Playtest_2026-11-06_0350` -> `Builds/MyGame_Local_2026-11-06.zip` (382 MB). Started: title with map 02, no errors.
- Not verified by a launch: clicking Play / Online in the builds (a Windows Firewall question for the game came up on the desktop and took the focus; it is left for the developer to answer); a two-process KCP or Steam game (no automation hook; covered by the loopback tests only).
- Cosmetic, not fixed: on the local build's title the place of the hidden Online word stays empty.
