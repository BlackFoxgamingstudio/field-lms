# Standard Operating Procedure: Sovereign Field Lms

## 1. Service Health Verification
Run `sovereign-field-lms --health` to confirm the engine responds with status `HEALTHY`.

## 2. Webhook Adapter Operation
The webhook adapter listens on port `8789`:
```bash
python3 n8n/webhook_adapter.py
```
If port 8789 is occupied, check active processes:
```bash
lsof -i :8789
```

## 3. n8n Integration Testing
Send a probe POST request:
```bash
curl -X POST http://localhost:8789/api/v1/execute \
  -H "Content-Type: application/json" \
  -d '{"action": "health_ping", "payload": {"test": true}}'
```
