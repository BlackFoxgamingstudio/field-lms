# Architecture: Sovereign Field LMS

## Overview

**Package ID:** `PKG-011`  
**Domain:** EdTech & Technical Curriculum  
**Microservice Port:** `8789`  
**n8n Webhook Path:** `field-lms-trigger`  
**GitHub:** [BlackFoxgamingstudio/field-lms](https://github.com/BlackFoxgamingstudio/field-lms)

Offline-first Learning Management System for field technicians. Delivers structured curriculum, competency assessments, and certification tracking on-device.

---

## System Architecture

```
                     ┌──────────────────────────────────┐
                     │       Sovereign Field LMS           │
                     │       Port: 8789            │
                     ├──────────────┬───────────────────┤
   n8n Webhook ────▶ │  REST API    │   Core Engine     │
   HTTP POST         │  /api/v1/*   │   Dispatcher      │
                     └──────┬───────┴────────┬──────────┘
                            │                │
              ┌─────────────▼────────────────▼─────────┐
              │          Component Layer                 │
              │  CurriculumEngin | AssessmentRunne | Certificatio  │
              └────────────────────────┬────────────────┘
                                       │
              ┌────────────────────────▼────────────────┐
              │      n8n Central Event Bus (:5678)       │
              └─────────────────────────────────────────┘
```

## Core Components

### `CurriculumEngine`
Handles all curriculum operations. Exposes async methods callable from the core dispatcher.

### `AssessmentRunner`
Handles all assessmentrunner operations. Exposes async methods callable from the core dispatcher.

### `CertificationTracker`
Handles all certificationtracker operations. Exposes async methods callable from the core dispatcher.

### `OfflineSyncManager`
Handles all offlinesync operations. Exposes async methods callable from the core dispatcher.

### `ProgressReporter`
Handles all progressreporter operations. Exposes async methods callable from the core dispatcher.

---

## API Contract

All interactions follow the SBB standard envelope:

```http
POST /api/v1/execute
Content-Type: application/json
X-SBB-API-Key: <api-key>

{
  "action": "<operation>",
  "payload": {},
  "trace_id": "optional-uuid"
}
```

**Success Response (HTTP 200):**
```json
{
  "status": "success",
  "data": {},
  "trace_id": "...",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

**Health Check:**
```http
GET /health
→ {"status": "healthy", "service": "sovereign-field-lms", "port": 8789}
```

## Integration Matrix

| System | Protocol | Direction | Purpose |
|--------|----------|-----------|---------|
| n8n Event Bus (:5678) | HTTP POST | Outbound | Event forwarding |
| n8n Webhook | HTTP POST | Inbound | Trigger execution |
| SBB Codebase Vault (:8766) | HTTP | Outbound | Code analysis |
| SBB Patterns Bible (:8794) | HTTP | Outbound | Standards validation |
| External APIs | HTTPS | Outbound | Domain-specific data |

## Deployment Architecture

```yaml
# docker-compose excerpt
sovereign-field-lms:
  image: sovereign-field-lms:latest
  ports: ["8789:8789"]
  healthcheck:
    test: curl -f http://localhost:8789/health
    interval: 30s
```

## Security Model

| Control | Implementation |
|---------|---------------|
| Authentication | `X-SBB-API-Key` header (env: `SBB_API_KEY`) |
| Rate Limiting | 100 req/min per client IP |
| Input Validation | Pydantic models (strict mode) |
| Container Security | Non-root user (`appuser:1001`) |
| Secrets | Environment variables only (never hardcoded) |
| TLS | Terminate at reverse proxy (nginx/caddy) |

## Tags
`lms`, `edtech`, `offline`, `certification`
