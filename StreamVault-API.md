# StreamVault API Documentation

**Base URL:** `/api/v1`
**Version:** 1.0
**License:** GPL-3.0

## Overview

StreamVault is a Twitch VOD and Live Stream archiving platform. Authentication is handled using JWT tokens set as `access-token` and `refresh-token` cookies.

---

## Authentication

All protected endpoints require cookie-based authentication:
- **Type:** API Key (Cookie)
- **Cookie Name:** `access-token`

---

## Endpoints

### Admin

#### Get Info
```
GET /admin/info
```
Get StreamVault system info including version, uptime, and program versions.

**Response:** `200 OK`
```json
{
  "version": "string",
  "git_hash": "string",
  "build_time": "string",
  "uptime": "string",
  "program_versions": {
    "ffmpeg": "string",
    "twitch_downloader": "string",
    "chat_downloader": "string",
    "streamlink": "string"
  }
}
```

#### Get Stats
```
GET /admin/stats
```
Get system statistics.

**Response:** `200 OK`
```json
{
  "vod_count": 0,
  "channel_count": 0
}
```

---

### Archive

#### Archive Channel
```
POST /archive/channel
```
Archive a Twitch channel (creates channel in database and downloads profile image).

**Request Body:**
```json
{
  "channel_name": "string" // required
}
```

**Response:** `200 OK` - Returns `Channel` object

#### Archive VOD
```
POST /archive/vod
```
Archive a Twitch VOD.

**Request Body:**
```json
{
  "vod_id": "string",      // required
  "quality": "best",       // required: best, source, 720p60, 480p30, 360p30, 160p30
  "chat": true,
  "render_chat": true
}
```

**Response:** `200 OK`
```json
{
  "vod": { /* Vod object */ },
  "queue": { /* Queue object */ }
}
```

#### Restart Task
```
POST /archive/restart
```
Restart a failed task.

**Request Body:**
```json
{
  "queue_id": "string",    // required
  "task": "string",        // required: vod_create_folder, vod_download_thumbnail, vod_save_info, video_download, video_convert, video_move, chat_download, chat_convert, chat_render, chat_move
  "cont": false
}
```

---

### Auth

#### Login
```
POST /auth/login
```
Login a user. Sets `access-token` (1 hour) and `refresh-token` (1 month) cookies.

**Request Body:**
```json
{
  "username": "string",    // required
  "password": "string"     // required
}
```

**Response:** `200 OK` - Returns `User` object

#### Register
```
POST /auth/register
```
Register a new user (does not log in).

**Request Body:**
```json
{
  "username": "string",    // required, 3-20 chars
  "password": "string"     // required, min 8 chars
}
```

**Response:** `200 OK` - Returns `User` object

#### Get Current User
```
GET /auth/me
```
Get the currently authenticated user.

**Response:** `200 OK` - Returns `User` object

#### Change Password
```
POST /auth/change-password
```
Change the current user's password.

**Request Body:**
```json
{
  "old_password": "string",
  "new_password": "string",        // min 8 chars
  "confirm_new_password": "string"
}
```

#### Refresh Token
```
POST /auth/refresh
```
Refresh access and refresh tokens.

#### OAuth Login
```
GET /auth/oauth/login
```
Initiate OAuth login flow.

#### OAuth Callback
```
GET /auth/oauth/callback
```
OAuth provider callback endpoint.

#### OAuth Logout
```
GET /auth/oauth/logout
```
Logout from OAuth session.

#### OAuth Refresh
```
GET /auth/oauth/refresh
```
Refresh OAuth tokens.

---

### Channel

#### List Channels
```
GET /channel
```
Get all channels.

**Response:** `200 OK` - Returns array of `Channel` objects

#### Get Channel
```
GET /channel/{id}
```
Get a channel by ID.

**Parameters:**
- `id` (path, required): Channel ID

**Response:** `200 OK` - Returns `Channel` object

#### Get Channel by Name
```
GET /channel/name/{name}
```
Get a channel by name.

**Parameters:**
- `name` (path, required): Channel name

**Response:** `200 OK` - Returns `Channel` object

#### Create Channel
```
POST /channel
```
Create a new channel.

**Request Body:**
```json
{
  "name": "string",         // required, 2-50 chars
  "display_name": "string", // required, 2-50 chars
  "image_path": "string"    // required, min 3 chars
}
```

**Response:** `200 OK` - Returns `Channel` object

#### Update Channel
```
PUT /channel/{id}
```
Update a channel.

**Parameters:**
- `id` (path, required): Channel ID

**Request Body:** Same as Create Channel

**Response:** `200 OK` - Returns `Channel` object

#### Delete Channel
```
DELETE /channel/{id}
```
Delete a channel.

**Parameters:**
- `id` (path, required): Channel ID

---

### Config

#### Get Config
```
GET /config
```
Get application configuration.

**Response:** `200 OK` - Returns `Config` object

#### Update Config
```
PUT /config
```
Update application configuration.

**Request Body:**
```json
{
  "registration_enabled": true,
  "archive": {
    "save_as_hls": false
  },
  "parameters": {
    "video_convert": "string",
    "chat_render": "string",
    "twitch_token": "string",
    "streamlink_live": "string"
  }
}
```

#### Get Notification Config
```
GET /config/notification
```
Get notification settings.

#### Update Notification Config
```
PUT /config/notification
```
Update notification settings.

**Request Body:**
```json
{
  "video_success_enabled": true,
  "video_success_webhook_url": "string",
  "video_success_template": "string",
  "live_success_enabled": true,
  "live_success_webhook_url": "string",
  "live_success_template": "string",
  "is_live_enabled": true,
  "is_live_webhook_url": "string",
  "is_live_template": "string",
  "error_enabled": true,
  "error_webhook_url": "string",
  "error_template": "string"
}
```

#### Get Storage Template Config
```
GET /config/storage
```
Get storage template settings.

#### Update Storage Template Config
```
PUT /config/storage
```
Update storage template settings.

**Request Body:**
```json
{
  "folder_template": "string",
  "file_template": "string"
}
```

---

### Exec

#### Get FFprobe Data
```
POST /exec/ffprobe
```
Get FFprobe data for a file.

**Request Body:**
```json
{
  "path": "string"  // required
}
```

**Response:** `200 OK` - Returns FFprobe JSON data

---

### Live (Watched Channels)

#### List Watched Channels
```
GET /live
```
Get all watched channels.

**Response:** `200 OK` - Returns array of `Live` objects

#### Add Watched Channel
```
POST /live
```
Add a channel to watch list.

**Request Body:**
```json
{
  "channel_id": "string",      // required
  "resolution": "best",        // required: best, source, 720p60, 480p30, 360p30, 160p30
  "archive_chat": true,
  "render_chat": true,
  "download_archives": true,
  "download_highlights": true,
  "download_uploads": true,
  "download_sub_only": false,
  "watch_live": true,
  "watch_vod": true,
  "categories": ["string"]
}
```

**Response:** `200 OK` - Returns `Live` object

#### Add Multiple Watched Channels
```
POST /live/multiple
```
Add multiple channels at once with the same settings.

**Request Body:**
```json
{
  "channel_id": ["string"],    // required, array of channel IDs
  "resolution": "best",        // required
  "archive_chat": true,
  "render_chat": true,
  "download_archives": true,
  "download_highlights": true,
  "download_uploads": true,
  "download_sub_only": false,
  "watch_live": true,
  "watch_vod": true,
  "categories": ["string"]
}
```

#### Update Watched Channel
```
PUT /live/{id}
```
Update watched channel settings.

**Parameters:**
- `id` (path, required): Channel ID

**Request Body:**
```json
{
  "resolution": "best",        // required
  "archive_chat": true,
  "render_chat": true,
  "download_archives": true,
  "download_highlights": true,
  "download_uploads": true,
  "download_sub_only": false,
  "watch_live": true,
  "watch_vod": true,
  "categories": ["string"]
}
```

#### Delete Watched Channel
```
DELETE /live/{id}
```
Remove a channel from watch list.

**Parameters:**
- `id` (path, required): Channel ID

#### Check Live Channels
```
GET /live/check
```
Manually trigger live channel check (normally runs automatically per config interval).

#### Archive Live Stream
```
POST /live/archive
```
Adhoc archive a channel's live stream.

#### Convert Chat
```
POST /live/chat-convert
```
Convert live stream chat to VOD chat format.

**Request Body:**
```json
{
  "vod_id": "string",
  "vod_external_id": "string",
  "channel_id": 0,
  "channel_name": "string",
  "file_name": "string",
  "chat_start": "string"
}
```

---

### Notification

#### Test Notification
```
GET /notification/test?type={type}
```
Send a test notification.

**Parameters:**
- `type` (query, required): Type of notification to test

---

### Playback

#### Get All Progress
```
GET /playback
```
Get all playback progress entries for the current user.

**Response:** `200 OK` - Returns array of `Playback` objects

#### Get Progress
```
GET /playback/progress/{id}
```
Get playback progress for a specific VOD.

**Parameters:**
- `id` (path, required): VOD ID

**Response:** `200 OK` - Returns `Playback` object

#### Update Progress
```
POST /playback/progress
```
Update playback progress.

**Request Body:**
```json
{
  "vod_id": "string",   // required
  "time": 0             // required, seconds
}
```

#### Update Status
```
POST /playback/status
```
Update playback status.

**Request Body:**
```json
{
  "vod_id": "string",           // required
  "status": "in_progress"       // required: in_progress, finished
}
```

#### Delete Progress
```
DELETE /playback/{id}
```
Delete playback progress for a VOD.

**Parameters:**
- `id` (path, required): VOD ID

---

### Playlist

#### List Playlists
```
GET /playlist
```
Get all playlists.

**Response:** `200 OK` - Returns array of `Playlist` objects

#### Get Playlist
```
GET /playlist/{id}
```
Get a playlist by ID.

**Parameters:**
- `id` (path, required): Playlist ID

**Response:** `200 OK` - Returns `Playlist` object with VODs

#### Create Playlist
```
POST /playlist
```
Create a new playlist.

**Request Body:**
```json
{
  "name": "string",        // required
  "description": "string"
}
```

**Response:** `200 OK` - Returns `Playlist` object

#### Update Playlist
```
PUT /playlist/{id}
```
Update a playlist.

**Parameters:**
- `id` (path, required): Playlist ID

**Request Body:** Same as Create Playlist

#### Delete Playlist
```
DELETE /playlist/{id}
```
Delete a playlist.

**Parameters:**
- `id` (path, required): Playlist ID

#### Add VOD to Playlist
```
POST /playlist/{id}
```
Add a VOD to a playlist.

**Parameters:**
- `id` (path, required): Playlist ID

**Request Body:**
```json
{
  "vod_id": "string"  // required
}
```

#### Remove VOD from Playlist
```
DELETE /playlist/{id}/vod
```
Remove a VOD from a playlist.

**Parameters:**
- `id` (path, required): Playlist ID

**Request Body:**
```json
{
  "vod_id": "string"  // required
}
```

---

### Queue

#### List Queue Items
```
GET /queue?processing={processing}
```
Get queue items.

**Parameters:**
- `processing` (query, optional): Filter by processing status

**Response:** `200 OK` - Returns array of `Queue` objects

#### Get Queue Item
```
GET /queue/{id}
```
Get a queue item by ID.

**Parameters:**
- `id` (path, required): Queue item ID

**Response:** `200 OK` - Returns `Queue` object

#### Create Queue Item
```
POST /queue
```
Create a queue item.

**Request Body:**
```json
{
  "vod_id": "string"  // required
}
```

**Response:** `201 Created` - Returns `Queue` object

#### Update Queue Item
```
PUT /queue/{id}
```
Update a queue item.

**Parameters:**
- `id` (path, required): Queue item ID

**Request Body:**
```json
{
  "id": "string",
  "processing": false,
  "on_hold": false,
  "video_processing": false,
  "chat_processing": false,
  "live_archive": false,
  "task_vod_create_folder": "pending",
  "task_vod_download_thumbnail": "pending",
  "task_vod_save_info": "pending",
  "task_video_download": "pending",
  "task_video_convert": "pending",
  "task_video_move": "pending",
  "task_chat_download": "pending",
  "task_chat_convert": "pending",
  "task_chat_render": "pending",
  "task_chat_move": "pending"
}
```

Task status values: `pending`, `running`, `success`, `failed`

#### Delete Queue Item
```
DELETE /queue/{id}
```
Delete a queue item.

**Parameters:**
- `id` (path, required): Queue item ID

#### Read Queue Log
```
GET /queue/{id}/tail?type={type}
```
Read queue log file.

**Parameters:**
- `id` (path, required): Queue item ID
- `type` (query, required): Log type - `video`, `video-convert`, `chat`, `chat-render`, `chat-convert`

---

### Task

#### Start Task
```
POST /task/start
```
Start a system task.

**Request Body:**
```json
{
  "task": "check_live"  // required: check_live, check_vod, get_jwks, twitch_auth, queue_hold_check, storage_migration
}
```

---

### Twitch

#### Get Channel
```
GET /twitch/channel?name={name}
```
Get a Twitch user/channel by name (uses Twitch API).

**Parameters:**
- `name` (query, required): Twitch user login name

**Response:** `200 OK`
```json
{
  "id": "string",
  "login": "string",
  "display_name": "string",
  "type": "string",
  "broadcaster_type": "string",
  "description": "string",
  "profile_image_url": "string",
  "offline_image_url": "string",
  "view_count": 0,
  "created_at": "string"
}
```

#### Get VOD
```
GET /twitch/vod?id={id}
```
Get a Twitch VOD by ID (uses Twitch API).

**Parameters:**
- `id` (query, required): Twitch VOD ID

**Response:** `200 OK` - Returns Twitch `Vod` object

#### Get Video (GraphQL)
```
GET /twitch/gql/video?id={id}
```
Get a Twitch video by ID (uses Twitch GraphQL API).

**Parameters:**
- `id` (query, required): Twitch video ID

**Response:** `200 OK` - Returns Twitch `Video` object

#### Get Categories
```
GET /twitch/categories
```
Get a list of Twitch categories.

**Response:** `200 OK` - Returns array of `Category` objects

---

### User

#### List Users
```
GET /user
```
Get all users (admin only).

**Response:** `200 OK` - Returns array of `User` objects

#### Get User
```
GET /user/{id}
```
Get a user by ID.

**Parameters:**
- `id` (path, required): User ID

**Response:** `200 OK` - Returns `User` object

#### Update User
```
PUT /user/{id}
```
Update a user.

**Parameters:**
- `id` (path, required): User ID

**Request Body:**
```json
{
  "username": "string",        // required, 2-50 chars
  "role": "user"               // required: admin, editor, archiver, user
}
```

**Response:** `200 OK` - Returns `User` object

#### Delete User
```
DELETE /user/{id}
```
Delete a user.

**Parameters:**
- `id` (path, required): User ID

---

### VOD

#### List VODs
```
GET /vod?channel_id={channel_id}
```
Get VODs, optionally filtered by channel.

**Parameters:**
- `channel_id` (query, optional): Filter by channel ID

**Response:** `200 OK` - Returns array of `Vod` objects

#### Get VODs (Paginated)
```
GET /vod/pagination?limit={limit}&offset={offset}&channel_id={channel_id}
```
Get VODs with pagination.

**Parameters:**
- `limit` (query, optional): Number of results (default: 10)
- `offset` (query, optional): Offset (default: 0)
- `channel_id` (query, optional): Filter by channel ID

**Response:** `200 OK`
```json
{
  "data": [/* Vod objects */],
  "total_count": 0,
  "limit": 10,
  "offset": 0,
  "pages": 1
}
```

#### Search VODs
```
GET /vod/search?q={query}&limit={limit}&offset={offset}
```
Search VODs by title.

**Parameters:**
- `q` (query, required): Search query
- `limit` (query, optional): Number of results (default: 10)
- `offset` (query, optional): Offset (default: 0)

**Response:** `200 OK` - Returns array of `Vod` objects

#### Get VOD
```
GET /vod/{id}?with_channel={with_channel}
```
Get a VOD by ID.

**Parameters:**
- `id` (path, required): VOD ID
- `with_channel` (query, optional): Include channel data

**Response:** `200 OK` - Returns `Vod` object

#### Create VOD
```
POST /vod
```
Create a VOD manually.

**Request Body:**
```json
{
  "id": "string",
  "ext_id": "string",
  "channel_id": "string",          // required
  "platform": "twitch",            // required: twitch, youtube
  "type": "archive",               // required: archive, live, highlight, upload, clip
  "title": "string",               // required
  "duration": 0,                   // required
  "views": 0,                      // required
  "resolution": "string",
  "processing": false,
  "thumbnail_path": "string",
  "web_thumbnail_path": "string",  // required
  "video_path": "string",          // required
  "chat_path": "string",
  "chat_video_path": "string",
  "info_path": "string",
  "caption_path": "string",
  "streamed_at": "string"          // required
}
```

**Response:** `201 Created` - Returns `Vod` object

#### Update VOD
```
PUT /vod/{id}
```
Update a VOD.

**Parameters:**
- `id` (path, required): VOD ID

**Request Body:** Same as Create VOD

**Response:** `200 OK` - Returns `Vod` object

#### Delete VOD
```
DELETE /vod/{id}?delete_files={delete_files}
```
Delete a VOD.

**Parameters:**
- `id` (path, required): VOD ID
- `delete_files` (query, optional): Also delete files from storage

#### Get VOD Chat
```
GET /vod/{id}/chat?start={start}&end={end}
```
Get chat comments for a VOD.

**Parameters:**
- `id` (path, required): VOD ID
- `start` (query, optional): Start time in seconds
- `end` (query, optional): End time in seconds

**Response:** `200 OK` - Returns array of `Comment` objects

#### Seek VOD Chat
```
GET /vod/{id}/chat/seek?start={start}&count={count}
```
Get N chat comments before a timestamp (for seeking).

**Parameters:**
- `id` (path, required): VOD ID
- `start` (query, optional): Start time in seconds
- `count` (query, optional): Number of comments

**Response:** `200 OK` - Returns array of `Comment` objects

#### Get VOD Chat Emotes
```
GET /vod/{id}/chat/emotes
```
Get emotes used in VOD chat.

**Parameters:**
- `id` (path, required): VOD ID

**Response:** `200 OK` - Returns emotes data

#### Get VOD Chat Badges
```
GET /vod/{id}/chat/badges
```
Get badges used in VOD chat.

**Parameters:**
- `id` (path, required): VOD ID

**Response:** `200 OK` - Returns badges data

#### Get VOD Chat User ID
```
GET /vod/{id}/chat/userid
```
Get the channel user ID from the chat JSON file.

**Parameters:**
- `id` (path, required): VOD ID

**Response:** `200 OK` - Returns user ID integer

#### Get VOD Playlists
```
GET /vod/{id}/playlist
```
Get playlists containing this VOD.

**Parameters:**
- `id` (path, required): VOD ID

**Response:** `200 OK` - Returns array of `Playlist` objects

---

## Data Models

### Channel
```json
{
  "id": "string",
  "ext_id": "string",
  "name": "string",
  "display_name": "string",
  "image_path": "string",
  "created_at": "string",
  "updated_at": "string",
  "edges": {
    "vods": [/* Vod objects */],
    "live": [/* Live objects */]
  }
}
```

### Vod
```json
{
  "id": "string",
  "ext_id": "string",
  "platform": "twitch",           // twitch, youtube
  "type": "archive",              // archive, live, highlight, upload, clip
  "title": "string",
  "duration": 0,
  "views": 0,
  "resolution": "string",
  "processing": false,
  "thumbnail_path": "string",
  "web_thumbnail_path": "string",
  "video_path": "string",
  "chat_path": "string",
  "chat_video_path": "string",
  "info_path": "string",
  "caption_path": "string",
  "folder_name": "string",
  "file_name": "string",
  "streamed_at": "string",
  "created_at": "string",
  "updated_at": "string",
  "edges": {
    "channel": { /* Channel */ },
    "queue": { /* Queue */ },
    "playlists": [/* Playlist objects */]
  }
}
```

### Live
```json
{
  "id": "string",
  "watch_live": true,
  "watch_vod": true,
  "download_archives": true,
  "download_highlights": true,
  "download_uploads": true,
  "download_sub_only": false,
  "is_live": false,
  "archive_chat": true,
  "render_chat": true,
  "resolution": "best",
  "last_live": "string",
  "created_at": "string",
  "updated_at": "string",
  "edges": {
    "channel": { /* Channel */ },
    "categories": [/* LiveCategory objects */]
  }
}
```

### Queue
```json
{
  "id": "string",
  "processing": false,
  "on_hold": false,
  "video_processing": false,
  "chat_processing": false,
  "live_archive": false,
  "chat_start": "string",
  "render_chat": false,
  "task_vod_create_folder": "pending",
  "task_vod_download_thumbnail": "pending",
  "task_vod_save_info": "pending",
  "task_video_download": "pending",
  "task_video_convert": "pending",
  "task_video_move": "pending",
  "task_chat_download": "pending",
  "task_chat_convert": "pending",
  "task_chat_render": "pending",
  "task_chat_move": "pending",
  "created_at": "string",
  "updated_at": "string",
  "edges": {
    "vod": { /* Vod */ }
  }
}
```

### User
```json
{
  "id": "string",
  "username": "string",
  "role": "user",              // admin, editor, archiver, user
  "oauth": false,
  "sub": "string",
  "webhook": "string",
  "created_at": "string",
  "updated_at": "string"
}
```

### Playlist
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "thumbnail_path": "string",
  "created_at": "string",
  "updated_at": "string",
  "edges": {
    "vods": [/* Vod objects */]
  }
}
```

### Playback
```json
{
  "id": "string",
  "vod_id": "string",
  "user_id": "string",
  "time": 0,
  "status": "in_progress",     // in_progress, finished
  "created_at": "string",
  "updated_at": "string"
}
```

### Comment (Chat)
```json
{
  "_id": "string",
  "channel_id": "string",
  "content_id": "string",
  "content_offset_seconds": 0.0,
  "content_type": "string",
  "created_at": "string",
  "updated_at": "string",
  "source": "string",
  "state": "string",
  "more_replies": false,
  "commenter": {
    "_id": "string",
    "name": "string",
    "display_name": "string",
    "logo": "string",
    "bio": "string",
    "type": "string",
    "created_at": "string",
    "updated_at": "string"
  },
  "message": {
    "body": "string",
    "bits_spent": 0,
    "is_action": false,
    "user_color": "string",
    "fragments": [{
      "text": "string",
      "emoticon": {
        "emoticon_id": "string",
        "emoticon_set_id": "string"
      }
    }],
    "emoticons": [{
      "_id": "string",
      "begin": 0,
      "end": 0
    }],
    "user_badges": [{
      "_id": "string",
      "version": "string"
    }],
    "user_notice_params": {
      "msg_id": "string"
    }
  }
}
```

### Config
```json
{
  "debug": false,
  "db_seeded": true,
  "registration_enabled": true,
  "oauth_enabled": false,
  "active_queue_items": 2,
  "live_check_interval_seconds": 300,
  "archive": {
    "save_as_hls": false
  },
  "parameters": {
    "video_convert": "string",
    "chat_render": "string",
    "twitch_token": "string",
    "streamlink_live": "string"
  },
  "notifications": { /* Notification config */ },
  "storage_templates": {
    "folder_template": "string",
    "file_template": "string"
  }
}
```

---

## Enums

### TaskStatus
- `pending` - Task not started
- `running` - Task in progress
- `success` - Task completed successfully
- `failed` - Task failed

### VodType
- `archive` - Full stream archive
- `live` - Live stream recording
- `highlight` - Stream highlight
- `upload` - Manual upload
- `clip` - Clip

### VideoPlatform
- `twitch`
- `youtube`

### VodQuality
- `best`
- `source`
- `720p60`
- `480p30`
- `360p30`
- `160p30`

### PlaybackStatus
- `in_progress`
- `finished`

### Role
- `admin` - Full access
- `editor` - Can edit content
- `archiver` - Can archive content
- `user` - Basic access

---

## Error Response

All error responses follow this format:
```json
{
  "message": "Error description"
}
```

Common HTTP status codes:
- `400` - Bad Request (invalid input)
- `401` - Unauthorized (not logged in)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate resource)
- `500` - Internal Server Error
