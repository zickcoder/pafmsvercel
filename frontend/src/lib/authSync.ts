/**
 * Real-time cross-tab authentication synchronization
 * Synchronizes login and logout immediately across all open browser tabs
 * using BroadcastChannel with localStorage storage-event fallback.
 */

export type AuthEventType = 'LOGIN' | 'LOGOUT';

export interface AuthEventPayload {
  type: AuthEventType;
  role?: string;
  timestamp: number;
}

const CHANNEL_NAME = 'govserve_auth_sync';
let broadcastChannel: BroadcastChannel | null = null;

try {
  if (typeof window !== 'undefined' && 'BroadcastChannel' in window) {
    broadcastChannel = new BroadcastChannel(CHANNEL_NAME);
  }
} catch {
  broadcastChannel = null;
}

/**
 * Broadcast an authentication event to all other open tabs
 */
export function broadcastAuth(type: AuthEventType, role?: string): void {
  if (typeof window === 'undefined') return;

  const payload: AuthEventPayload = {
    type,
    role,
    timestamp: Date.now()
  };

  // 1. Send via BroadcastChannel (instant in modern browsers)
  if (broadcastChannel) {
    try {
      broadcastChannel.postMessage(payload);
    } catch {}
  }

  // 2. Set localStorage key to trigger 'storage' event in other tabs
  try {
    localStorage.setItem('govserve_auth_event', JSON.stringify(payload));
  } catch {}
}

/**
 * Completely clean all session and local storage user tokens
 */
export function clearAllAuthStorage(): void {
  if (typeof window === 'undefined') return;

  const keys = [
    'govserve_citizen_user',
    'govserve_staff_user',
    'govserve_user',
    'govserve_portal',
    'govserve_resubmit_ticket'
  ];

  keys.forEach((k) => {
    try {
      sessionStorage.removeItem(k);
      localStorage.removeItem(k);
    } catch {}
  });

  try {
    window.dispatchEvent(new Event('govserve_data_updated'));
  } catch {}
}

/**
 * Listen for auth changes (login / logout) from other tabs
 */
export function subscribeToAuthEvents(
  onEvent: (payload: AuthEventPayload) => void
): () => void {
  if (typeof window === 'undefined') return () => {};

  // 1. BroadcastChannel listener
  const channelHandler = (e: MessageEvent) => {
    if (e.data && (e.data.type === 'LOGIN' || e.data.type === 'LOGOUT')) {
      onEvent(e.data);
    }
  };

  if (broadcastChannel) {
    broadcastChannel.addEventListener('message', channelHandler);
  }

  // 2. Storage event listener (cross-tab fallback)
  const storageHandler = (e: StorageEvent) => {
    if (e.key === 'govserve_auth_event' && e.newValue) {
      try {
        const parsed = JSON.parse(e.newValue);
        if (parsed && (parsed.type === 'LOGIN' || parsed.type === 'LOGOUT')) {
          onEvent(parsed);
        }
      } catch {}
    } else if (
      (e.key === 'govserve_citizen_user' || e.key === 'govserve_staff_user' || e.key === 'govserve_user')
    ) {
      if (!e.newValue) {
        // A user key was deleted in another tab -> LOGOUT
        onEvent({ type: 'LOGOUT', timestamp: Date.now() });
      } else {
        // A user key was created in another tab -> LOGIN
        onEvent({ type: 'LOGIN', timestamp: Date.now() });
      }
    }
  };

  window.addEventListener('storage', storageHandler);

  return () => {
    if (broadcastChannel) {
      broadcastChannel.removeEventListener('message', channelHandler);
    }
    window.removeEventListener('storage', storageHandler);
  };
}
