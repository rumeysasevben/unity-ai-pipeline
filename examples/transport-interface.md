# One interface, swappable backends

The game's networking sits behind a single interface. Nothing else in the game sees the networking library: a real transport (Mirror over KCP, Steam) and a loopback transport used by tests and latency experiments both implement it. Game code never learns which one is running.

This is the same pattern as a unified wrapper over several third-party SDKs: the integration surface for game teams stays small and stable while what sits behind it changes.

```csharp
using System;

namespace MyGame.Net
{
    /// <summary>
    /// Carries byte payloads between the two machines of a session. Nothing else of the game sees
    /// the networking library: Mirror sits behind MirrorTransport, the tests and the latency experiments
    /// behind LoopbackTransport. A session has exactly two ends, so there is no addressing: the host
    /// sends to its client, the client to its host.
    /// </summary>
    public interface INetworkTransport
    {
        NetRole Role { get; }

        /// <summary>True while the other machine is connected.</summary>
        bool PeerConnected { get; }

        event Action PeerJoined;

        event Action PeerLeft;

        /// <summary>
        /// Sends the payload to the other machine; the bytes are copied before it returns. Does nothing
        /// while no peer is connected. A payload above the protocol's maximum throws.
        /// </summary>
        void Send(NetChannel channel, ArraySegment<byte> payload);

        /// <summary>
        /// The next payload that has arrived, oldest first. The segment stays valid until the next call; copy what has
        /// to live longer.
        /// </summary>
        bool TryReceive(out ArraySegment<byte> payload);
    }
}
```

## What this buys

- **Tests without a network.** The loopback implementation lets online logic run in ordinary PlayMode tests (36 online PlayMode tests, 68 net EditMode tests).
- **A hard rule that can be tested.** "No networking-library types outside the net assembly" is enforced by assembly definitions: only the net assemblies reference the library, so a violation elsewhere fails the compile.
- **A byte budget that can be tested.** The maximum payload is part of the protocol; a test checks the real scene's world state against it. This is how an overnight audit caught a 1,234-byte state that did not fit a 1,015-byte packet.
