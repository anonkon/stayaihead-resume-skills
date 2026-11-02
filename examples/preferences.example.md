# Application Preferences

> This is an example. Run `/build-profile` to generate your own at `~/.claude/resume/preferences.md` - do not commit your real preferences to a public repo.

## Roles to avoid
No defence contractors, no gambling industry.

## Seniority
Mid-level only - not junior, not staff/principal.

## Visa / work rights
Requires sponsorship-friendly employers only (not authorised to work without sponsorship).

## Cover letter tone
Direct and specific. No corporate boilerplate. Avoid "I am writing to express my interest."
Short paragraphs, 3 to 5 sentences. Close with something brief and human, e.g. "Happy to discuss further."

## Phrases to avoid
"synergy", "team player", "results-driven", "passionate about technology"

These are checked with a grep in `tailor-job` Step 6b, so list literal words and
phrases rather than descriptions of a tone. `tailor-job` already bans dashes as
punctuation, semicolons, colons outside URLs and standard names, and a long list of
AI vocabulary, so this section is only for what you want banned on top of that.

## Job title reframing
Present the "Junior Data Wrangler" title as "Data Analyst" on tailored CVs.

## LaTeX conventions
1-page CV, 10pt, Latin Modern. No tables in the skills section, no vertical bars.
Skills category labels bold on their own line with terms on the line beneath.
Summary always the first section, skills always the last. Everything in between may
be reordered to suit the role.

## What to emphasise (by role type)
- **Data / analytics**: the 40k-row pipeline, SQL depth, the dashboard rollout
- **Platform / backend**: the API rewrite, on-call experience, Postgres tuning
- **Graduate programs**: real delivery experience compared to a typical graduate

## Working directory
~/resume-applications/

## Git
Optional. Only set this if the working directory is its own **private** repo.
- Remote: https://github.com/you/resume-applications (private)
- Branch: main
- Commit message format: `Add application: {Role} at {Company}`
