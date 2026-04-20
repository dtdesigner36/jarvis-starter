# Tier 2: real-time-app

**Stack:** Next.js + Socket.io/Pusher/Ably, or Supabase Realtime
**Key files:** gateway/, rooms/, events/, client hooks
**Skills:** `/api-contract`, `/new-system`
**Wiki folders:** Events/, Rooms/, Presence/, Reconnection/
**Triggers:**
- WS event changed → check client handlers
- Room logic → wiki/Rooms/
**Pitfalls:**
- No reconnection logic
- Memory leaks on forgotten subscriptions
- No rate limiting on WS messages
- Broadcasting to all when only a group is needed
- No clock sync → wrong timestamps
