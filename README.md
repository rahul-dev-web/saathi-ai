# SAATHI AI

A local-first, voice-enabled personal AI agent inspired by JARVIS / F.R.I.D.A.Y.

## Product direction

SAATHI is intended to grow beyond a chatbot. It should understand a user-approved profile and schedule, remember useful context, offer proactive reminders and next steps, and perform approved actions across Windows, browser workflows and a paired Android companion.

## Local-first AI

- **Runtime:** Ollama on the Windows laptop.
- **Starter model:** `qwen3.5:0.8b` for the first hardware proof of concept.
- **Possible next test:** `qwen3.5:2b`, only after measuring available memory.
- **Speech-to-text target:** local `whisper.cpp` evaluation.
- **Speech output baseline:** existing offline `pyttsx3` service.
- **Backend:** FastAPI.
- **Mobile client:** Flutter Android companion.

A local LLM avoids hosted-model API quotas, but model quality and speed remain limited by CPU, RAM, storage and power. Internet is still required for live web search and online booking workflows.

## Current baseline

The current `main` branch still contains Groq-specific chat and transcription services. The migration plan and source audit are in [the local-first roadmap](docs/SAATHI_AI_Local_First_Roadmap_v2.md). This documentation branch does not change production code.

## Priorities

1. Verify local Ollama performance on the actual laptop.
2. Introduce an LLM provider abstraction and replace the Groq chat path with Ollama.
3. Replace hosted transcription with local speech recognition.
4. Add a bounded tool-calling agent with approval gates.
5. Add structured profile, memory, schedule and event-driven proactive assistance.
6. Add browser booking helpers and Android companion integration.

## Safety principles

The model may propose actions; the application validates and controls them. Booking submission, payments, messages, calls and destructive actions require explicit user approval. Do not expose unrestricted terminal commands to the model or bypass OTP / CAPTCHA protections.

See [docs/SAATHI_AI_Local_First_Roadmap_v2.md](docs/SAATHI_AI_Local_First_Roadmap_v2.md) for architecture, repository findings, phases and acceptance criteria.
