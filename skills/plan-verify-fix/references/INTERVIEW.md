# Interview question sets

Ask only what the request, the issue and the code don't already answer. Up to 4 questions per round, each with 2–4
concrete options and the recommended one first. Stop as soon as you can write the end-to-end check.

## Feature

Round 1: scope and done

- **Outcome:** what can a user do afterwards that they can't now? Offer the 2–3 readings you see.
- **Done:** which check proves it works end to end? (an e2e test of a named flow, an API call and its response, a
  screenshot against a mockup)
- **Out of scope:** list the tempting extras you noticed and ask which are out.
- **Size:** one sitting, or planned in stages? This decides how many tasks to aim for.

Round 2: decisions (only the ones that are open)

- Data: new tables or fields, migrations, whether existing data needs backfilling.
- Interfaces: routes, components, CLI flags or API shapes that other code or people depend on.
- Dependencies: may you add a library? Which versions are pinned?
- Edge cases the user already knows about: empty states, permissions, limits, errors.

Round 3: risk (rarely needed)

- Rollout: feature flag, migration order, anything that must stay backwards compatible.
- Anything that needs a human to check (design sign-off, a real device, a third-party dashboard).

## Bug

Round 1: the symptom

- **Expected vs. actual:** confirm your one-line reading of each.
- **Reproduction:** steps, input or account that shows it. Always, sometimes, or once?
- **Where:** environment and version (local, preview, production; browser or runtime).
- **Done:** fixed when which check passes? Usually "the reproduction test passes and nothing else fails".

Round 2: boundaries (only when unclear)

- Since when? A release, a deploy or a dependency upgrade narrows the search.
- Impact: who is affected, and is a quick mitigation needed before the real fix?
- Out of scope: related problems to leave for separate issues.

## Small

No interview. Restate the change in one sentence and name the check. If either takes more than a sentence, it
isn't small: switch to Feature.
