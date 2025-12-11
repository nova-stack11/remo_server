// ignore_for_file: constant_identifier_names

enum UserClientEventType {
  USER_INVENTORY,
  GARDEN_EVENT,
  HOME_EVENT,

  // Chat events
  CHAT_MESSAGE,        // Send message
  CHAT_TYPING,         // Typing indicator
  MARK_READ,           // Mark messages as read

  // Friend events
  FRIEND_REQUEST,      // Friend system actions (send, accept, decline, cancel)

  // Group events
  GROUP_ACTION;        // Group management (create, add_member, remove_member, leave)
}

enum UserServerEventType {
  USER_INVENTORY,
  PLOT_SEED,
  GARDEN_EVENT_RESULT,
  HOME_RESULT,

  // Chat events
  CHAT_MESSAGE_RECEIVED,    // New message from others
  CHAT_MESSAGE_STATUS,      // Message status update (delivered/seen)
  TYPING_INDICATOR,         // Someone is typing

  // Friend events
  FRIEND_REQUEST_RECEIVED,  // Incoming friend request
  FRIEND_STATUS_CHANGED,    // Friend online/offline/away

  // Group events
  GROUP_EVENT;              // Group updates (member added/removed, group created, etc.)
}

