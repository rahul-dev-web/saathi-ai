# SAATHI AI — Local-First JARVIS / F.R.I.D.A.Y. Roadmap

**Version:** 2.0  
**Snapshot:** 5 November 2026  
**Repository:** `rahul-dev-web/saathi-ai`, branch `main`

This is a practical build plan, not a claim that the reference video's private source code or exact stack has been identified.

## 1. Product vision

SAATHI should become a personal AI agent, not just a chatbot. It should converse by voice, gradually understand the user's profession and projects, remember confirmed preferences and routines, provide timely proactive suggestions, and execute approved actions across Windows, browsers and a paired Android phone.

### Target capabilities

- Understand English, Hindi and Hinglish naturally.
- Learn the user's profession, education, active projects, skills, goals, routine, preferences and commitments through gradual, contextual onboarding.
- Remember useful facts with controls to inspect, correct and delete them.
- Notice relevant times and events: upcoming tasks, schedule conflicts, reminders, call duration and next steps.
- Use voice, browser tools, desktop tools and an Android companion.
- Assist with ticket booking and government workflows: research, explain requirements, prepare forms and guide the user through official websites.
- Require user review before external actions such as submitting bookings, sending messages or making payments.

Examples of intended proactive behaviour:
- “It is 8:20 PM. You have a task due at 9 PM. Would you like to start it now?”
- “Your call ended after 18 minutes. It is 8:42 PM; your next scheduled item is at 9 PM.”
- “I noticed this is a recurring project task. Should I remember that as part of your routine?”

These examples must be driven by user-approved context, not assumptions.

## 2. Local does not mean literally unlimited

A local model removes per-request hosted API quotas and per-token API charges for LLM inference. Once downloaded, it can run without an internet connection. But it is not without limits: CPU speed, RAM, storage, cooling, power, context length and the model's licence still matter. Live search, current ticket availability, email sync and online bookings still need internet access.

Known development machine: Dell Latitude 5490, 7th-generation Intel Core i5, 8 GB RAM, integrated graphics, 256 GB SATA SSD, Windows 11 Pro. This is a CPU-only, memory-constrained host. The goal is to prove a small model works acceptably, not to promise frontier-model performance.

## 3. Local AI choice

### Runtime: Ollama

Use Ollama for the first Windows prototype. It runs as a Windows application and exposes a local HTTP API, normally at `http://127.0.0.1:11434`. SAATHI's backend should call this local API. Do not expose the Ollama port to the public internet.

### Model: begin with Qwen3.5 0.8B

Starter command:

```powershell
ollama run qwen3.5:0.8b
```

Ollama lists this model tag at approximately 1.2–1.3 GB. The Qwen3.5-0.8B model card lists Apache 2.0. It is a feasibility model for local chat, language behaviour and backend wiring; its small size means it should not be trusted for complex multi-step reasoning or unsupervised tool execution.

Only after measuring RAM pressure should we test:

```powershell
ollama run qwen3.5:2b
```

Ollama lists this tag at approximately 2.7–3.1 GB. Its runtime and context require additional memory, so it may be uncomfortable on 8 GB RAM. Do not begin with 4B, 9B or 7B+ on this laptop.

Start with a 2K–4K context and one model request at a time. A model's advertised maximum context is not a sensible default on a constrained laptop.

### Speech

- **STT:** replace Groq Whisper with local `whisper.cpp`; evaluate compact multilingual CPU models on real Hindi, English and Hinglish recordings.
- **TTS:** preserve the existing `pyttsx3` service as the first offline baseline; test the installed Windows voices and Android playback. Evaluate a neural offline TTS later only if language coverage and licence are suitable.
- Keep push-to-talk at first. Wake-word / always-listening behaviour comes later, after privacy and reliability tests.

## 4. Target architecture

```text
Windows laptop
  Flutter / desktop interface
       |
  Local FastAPI backend
       |-- conversation manager
       |-- profile + memory
       |-- schedule / proactive event engine
       |-- bounded agent loop + tool registry
       |-- policy + approval queue + audit log
       |-- LLM provider: Ollama / local Qwen
       |-- STT provider: whisper.cpp
       |-- TTS provider: pyttsx3
       |
       +-- Playwright browser tools
       +-- approved Windows app tools

Paired Flutter Android companion
  microphone / speaker / notifications
  contact picker / ACTION_DIAL
  call-state events / explicit approvals
```

The laptop hosts the primary LLM. The phone is initially a companion UI and permission bridge. When the laptop is off, laptop-hosted AI is unavailable unless a separate on-device model is deliberately added later. The phone should connect to the SAATHI backend over trusted Wi-Fi initially; remote access should use a private authenticated VPN, not public port forwarding.

## 5. Repository audit (public main branch)

Useful work already present:
- FastAPI backend with auth, user, chat and voice routes.
- Flutter app folders for auth, home, chat, voice, profile, settings and device features.
- `memory_service.py` provides basic JSON-file memory and keyword search.
- `offline_tts_service.py` already uses `pyttsx3`.
- Flutter has audio recording and playback dependencies.

Findings to fix:
- `backend/app/services/groq_ai_service.py` calls Groq and hardcodes `llama-3.1-8b-instant`; chat and voice routes directly use this service.
- `backend/app/services/groq_voice_service.py` uses Groq Whisper for STT.
- `backend/app/core/config.py` includes a placeholder Groq key as a default; vendor secrets should never have defaults in code.
- `frontend/lib/core/constants.dart` hardcodes the Render-hosted API URL. Local-first mode needs a configurable local backend URL.
- Chat currently makes a single LLM call; an agent/tool loop was not found in the inspected code.
- Memory is a prototype JSON file with keyword matching; no schedule-aware proactive engine was found in the inspected source search.
- No Playwright booking workflow was found in the inspected source search.
- No root README was present; the frontend README is Flutter starter text.

Audit boundary: this inspection covers the public `main` branch. It does not reveal uncommitted files in the local `C:\rahul\ai\saathi-ai` folder. Back up and diff that folder before migrating code.

## 6. Memory and proactive design

SAATHI should ask about the user's profession, responsibilities, goals, projects and routine when that context becomes useful—not force a long setup form.

Recommended memory categories:
- Confirmed profile facts
- Preferences
- Projects and blockers
- Schedule and deadlines
- Explicit commitments
- Unconfirmed inferences

An inference should not silently become a permanent fact. Ask “I noticed you usually do this around this time. Should I remember that?” and provide inspect / edit / delete controls.

Use an event-driven design:
1. A deterministic scheduler or approved integration detects an event.
2. A context builder retrieves only relevant facts.
3. The local LLM writes a concise suggestion.
4. A notification policy decides whether to speak now, defer or suppress it.
5. The user can snooze, dismiss or disable that type of prompt.

Initial triggers: local time, user-defined routine, reminders, deadlines, calendar events after permission, approved project milestones and Android call-state events where Android permissions permit. Call-time behaviour should use call metadata only; do not record or transcribe the call.

## 7. Tool execution and permissions

The LLM must never receive unrestricted PowerShell or shell access. It can propose a named tool call; the application validates arguments, applies policy and runs only an allowlisted function.

- Low-risk read-only actions: tell time, open an approved app, search a public page.
- Medium-risk reversible actions: create a reminder, draft a message, prepare a form or cart.
- High-risk external actions: send, call, book, submit, pay or delete — require explicit confirmation immediately before the action.
- Not allowed in v1: arbitrary shell commands, hidden data collection, OTP/PIN/CVV capture, CAPTCHA bypass and silent payment.

Booking / government assistance can research official options, explain requirements and prepare form entries. The user reviews personal details and confirms final submission or payment. OTP and CAPTCHA remain under direct user control. Website-specific reliability must be tested; universal automation cannot be promised.

## 8. Implementation phases

### Phase 0 — documentation and baseline (started)
- Capture the local-first vision, architecture and acceptance criteria.
- Audit existing Groq, voice, memory and Flutter connection paths.
- Keep changes on a separate branch; do not disturb `main`.
- Compare the local working copy before code migration.

### Phase 1 — local-model proof of concept
- Install Ollama; run Qwen3.5 0.8B.
- Test offline chat in English, Hindi and Hinglish.
- Measure RAM, latency, temperature and available storage.
- Test Qwen3.5 2B only if enough RAM headroom remains.

### Phase 2 — replace Groq LLM
- Add an `AIProvider` contract and local Ollama implementation.
- Move provider URL and model ID into validated settings.
- Preserve chat API shapes initially to limit Flutter changes.
- Add a health endpoint and mocked / local integration tests.
- Remove Groq LLM dependencies only after all call sites are migrated.

### Phase 3 — local voice
- Add `whisper.cpp` STT adapter.
- Ensure Flutter recording format matches backend upload handling.
- Keep `pyttsx3` as first TTS baseline.
- Clean temporary audio on both success and error.

### Phase 4 — tool-calling agent
- Add strict tool schemas, allowlist, bounded agent loop, timeouts, cancel and audit.
- Start with time, approved app launch, approved website open and reminders.

### Phase 5 — profile, memory and proactive engine
- Migrate JSON memory to a stable local database.
- Add structured profile and user-managed memory.
- Add event-driven reminders, quiet hours and proactive summaries.
- Add call-state event relay only after Android permission testing.

### Phase 6 — browser / booking assistance
- Use Playwright with a separate browser profile.
- Begin read-only; then allow drafts and cart preparation.
- Confirm before submission / payment.

### Phase 7 — Android companion
- Pair phone and laptop with a one-time code / QR and revocable token.
- Add notifications, voice capture, contact picker, dialer handoff and call-state relay.
- Start on trusted Wi-Fi; secure remote access later.

## 9. First setup checklist

1. Check idle RAM usage and free disk space in Windows Task Manager.
2. Install Ollama for Windows from its official site.
3. In PowerShell run `ollama --version`.
4. Run `ollama run qwen3.5:0.8b`.
5. Test 5–10 short English / Hindi / Hinglish prompts.
6. Check Task Manager while the model is loaded.
7. Reboot and confirm the model remains available locally.
8. Do not download a larger model until the first test is measured.

## 10. First milestone acceptance

- Model downloads and responds through Ollama without a provider API key.
- FastAPI calls the model using a provider adapter.
- Existing Flutter chat can send a message to the laptop-local backend.
- A local spoken response is produced by the offline TTS service.
- The app reports local model unavailability instead of silently falling back to a hosted API.
- No action is executed unless a named tool, schema and policy allow it.

## 11. Research references

- Ollama Windows: https://github.com/ollama/ollama/blob/main/docs/windows.mdx
- Ollama API / tool calling: https://github.com/ollama/ollama/blob/main/docs/api.md
- Ollama FAQ / context and concurrency: https://github.com/ollama/ollama/blob/main/docs/faq.mdx
- Qwen3.5 model family and tag sizes: https://ollama.com/library/qwen3.5
- Qwen3.5-0.8B model card: https://huggingface.co/Qwen/Qwen3.5-0.8B
- Qwen3.5-0.8B licence: https://huggingface.co/Qwen/Qwen3.5-0.8B/blob/main/LICENSE
- whisper.cpp: https://github.com/ggml-org/whisper.cpp

**This is a build plan, not a production-readiness claim. Test each milestone on the actual laptop and phone.**
