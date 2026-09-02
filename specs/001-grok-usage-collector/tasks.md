# Tasks: Grok usage collector

**Input**: Design documents from `/specs/001-grok-usage-collector/`

## Phase 1: Setup

- [x] T001 Spec Kit constitution, spec, plan, research, data-model, contracts
- [x] T002 Create `bin/`, `test/`, `assets/`, `contrib/systemd/`
- [x] T003 [P] Add MIT LICENSE, README, .gitignore

## Phase 2: Foundational

- [x] T004 Implement `bin/omarchy-agent-usage-grok` (scan + cache + ACP billing + record)
- [x] T005 [P] Official Grok SVG pair in `assets/`
- [x] T006 Fixture test `test/agent-usage-grok-scanner-test.sh`

## Phase 3: User Story 1 — local sessions (P1)

- [x] T007 [US1] Nested `turn_completed` usage → panel buckets with cache split
- [x] T008 [US1] Flat `event_name` turns, prompt_id dedupe, subagent skip
- [x] T009 [US1] Ignore events.jsonl / chat_history.jsonl

## Phase 4: User Story 2 — billing (P1)

- [x] T010 [US2] Weekly/monthly limits, plan label, cents, omit zero prepaid
- [x] T011 [US2] 401 vs non-auth errors; skip mise/ACP noise

## Phase 5: User Story 3 — other harnesses (P2)

- [x] T012 [US3] pi/omp xai, xai-auth, xai-oauth; OpenCode xai; no interrupted-scan cache

## Phase 6: User Story 4 — install here (P1)

- [x] T013 [US4] `install.sh` + systemd user timer
- [x] T014 [US4] Run install on this host and verify `grok.json`
- [x] T015 [US4] Refresh `omarchy.agents` and confirm the record is ready

## Phase 7: Publish

- [ ] T016 Create GitHub repo, push `001-grok-usage-collector`
- [x] T017 Document upstream path to `omacom/omarchy` (quattro)
