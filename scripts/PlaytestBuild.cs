using System;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace MyGame.Editor.Build
{
    /// <summary>
    /// Windows playtest build, runnable from the menu or in batch mode:
    ///   Unity.exe -batchmode -quit -projectPath . -executeMethod MyGame.Editor.Build.PlaytestBuild.Build
    /// Output goes to Builds/Playtest_[date]/ (git-ignored); zip it and send it, it needs no Unity.
    /// It refuses to build when a pre-build check fails and exits with code 1 in batch mode,
    /// so a script (or an agent) can tell "built" from "did not build".
    /// </summary>
    internal static class PlaytestBuild
    {
        // The scene list is explicit, so a build never depends on whatever the Build Settings window holds today.
        private static readonly string[] Scenes =
        {
            "Assets/_Project/Scenes/Boot.unity",
            "Assets/_Project/Scenes/MainMenu.unity",
            "Assets/_Project/Scenes/Game_Gameplay.unity",
            "Assets/_Project/Scenes/Game_Map.unity",
        };

        /// <summary>
        /// A pre-build gate: a developer switch ("events start by hand only") that is fine in the Editor but would make
        /// a playtest meaningless. Read from the scene file so the check works without loading the scene.
        /// </summary>
        internal static bool EventsStartByThemselves()
        {
            string scene = File.ReadAllText("Assets/_Project/Scenes/Game_Gameplay.unity");
            return !Regex.IsMatch(scene, @"^\s*_autoStart: 0\s*$", RegexOptions.Multiline);
        }

        [MenuItem("Tools/Build/Playtest Build (Windows)")]
        public static void Build()
        {
            if (!EventsStartByThemselves())
            {
                Fail("Events are set to start by hand only in the gameplay scene: players would never meet one. " +
                     "Switch them back, then build again.");
                return;
            }

            if (!WindowsGraphicsApi.EnsureForBuild())
            {
                Fail("The graphics API is not the one this build must use (see WindowsGraphicsApi).");
                return;
            }

            string folder = Path.Combine("Builds", $"Playtest_{DateTime.Now:yyyy-MM-dd_HHmm}");
            var options = new BuildPlayerOptions
            {
                scenes = Scenes,
                locationPathName = Path.Combine(folder, $"{PlayerSettings.productName}.exe"),
                target = BuildTarget.StandaloneWindows64,
                targetGroup = BuildTargetGroup.Standalone,
                options = BuildOptions.None,
            };

            BuildSummary summary = BuildPipeline.BuildPlayer(options).summary;
            if (summary.result == BuildResult.Succeeded)
            {
                Debug.Log($"[Build] Playtest build ready: {Path.GetFullPath(folder)} " +
                          $"({summary.totalSize / (1024f * 1024f):F0} MB, {summary.totalTime.TotalSeconds:F0} s)");
            }
            else
            {
                Fail($"Playtest build {summary.result}: {summary.totalErrors} error(s). See the log above.");
            }
        }

        private static void Fail(string message)
        {
            Debug.LogError("[Build] " + message);
            if (Application.isBatchMode)
            {
                EditorApplication.Exit(1);
            }
        }
    }
}
