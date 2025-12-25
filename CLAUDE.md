# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StreamVault (originally Ganymede) is a Twitch VOD and Live Stream archiving platform with real-time chat playback. It archives videos with rendered chat for viewing outside the platform, saving files in standard formats.

## Development Commands

```bash
# Initial setup (install Go tools and npm packages)
make dev_setup

# Development servers (run in separate terminals)
make dev_server    # API server with hot reload (port 4000)
make dev_worker    # Background job worker with hot reload
make dev_web       # Next.js frontend (port 3000)

# Build
make build_server  # Build API binary
make build_worker  # Build worker binary

# Database
make ent_generate     # Regenerate Ent ORM code after schema changes
make ent_new_schema   # Create new database entity schema

# Quality
make lint    # Run golangci-lint
make test    # Run Go tests

# Utilities
make river-tui       # River job queue monitoring UI
make go_update_packages
make web_update
```

## Architecture

### Backend (Go)

Two separate binaries from a shared codebase:
- **Server** (`cmd/server/main.go`): Echo HTTP API serving REST endpoints
- **Worker** (`cmd/worker/main.go`): River queue consumer for background jobs

Key packages in `internal/`:
- `transport/http/`: HTTP handlers (vod.go, channel.go, queue.go, live.go, auth.go, etc.)
- `archive/`, `vod/`, `channel/`, `queue/`, `live/`: Domain services
- `tasks/`: River job definitions (video.go, chat.go, thumbnail.go, live_video.go, live_chat.go)
- `exec/`: External tool wrappers (ffmpeg.go, twitch.go, ytdlp/)
- `platform/`: Twitch API integration via GraphQL

### Database (Ent ORM)

Schemas in `ent/schema/`: vod.go, channel.go, user.go, queue.go, live.go, playlist.go, playback.go, chapter.go

After modifying schemas, run `make ent_generate` to regenerate the ORM code.

### Frontend (Next.js)

Located in `frontend/` using App Router:
- `app/(pages)/`: Route pages (videos, channels, queue, playlists, admin)
- `app/components/`: Reusable React components
- `app/hooks/`: Custom hooks
- `app/store/`: Zustand state stores
- `app/services/`: API client services

Tech stack: React 19, Mantine 8 (UI), Zustand (state), TanStack Query (server state), Vidstack (video player), next-intl (i18n)

### External Tools

The application shells out to:
- **TwitchDownloader**: Chat download and rendering
- **yt-dlp**: Video downloading
- **FFmpeg**: Video processing

### Background Jobs

River queue system with PostgreSQL backend. Jobs defined in `internal/tasks/`:
- Video/chat download for VODs and live streams
- Chat rendering
- Thumbnail sprite generation
- Watchdog monitoring

## Key Patterns

- Services follow constructor injection pattern with Ent client
- HTTP handlers use Echo's context with custom middleware for auth
- Configuration via environment variables (see `internal/config/env.go`) and JSON file at `/data/config/config.json`
- Logging uses zerolog with structured JSON output
- API documentation auto-generated via Swag annotations

## Testing

```bash
make test                           # All Go tests
go test -v ./internal/vod/...       # Single package
go test -v -run TestName ./...      # Single test
```

Tests use testcontainers for PostgreSQL integration tests.
