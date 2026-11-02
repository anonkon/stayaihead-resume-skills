---
name: build-profile
description: Build or update the user's career profile and application preferences from their CV, LinkedIn, GitHub, or conversation. Writes structured profile.md and preferences.md files used by the tailor-job skill. Use when the user invokes /build-profile, wants to update their profile, has new experience/projects/certs to add, or wants to change application preferences.
---

# build-profile

Collect everything needed to generate tailored job applications. Output goes to two shared files in your home directory:
- `~/.claude/resume/profile.md` - career facts
- `~/.claude/resume/preferences.md` - application rules and tone preferences

These files live outside this repo and outside any project folder - they are personal data and should never be committed to a public git repository. See the README's Privacy section.

## Process

### Step 1 - Read existing files first
Always read both files before asking anything:
```
~/.claude/resume/profile.md
~/.claude/resume/preferences.md
```
If they exist, show the user what's already there and ask what they want to update. If they don't exist yet, create the `~/.claude/resume/` directory.

### Step 2 - Gather sources
Ask the user to provide any of:
- CV / resume text or file path
- LinkedIn URL or exported PDF
- GitHub username
- Any additional context (new roles, projects, certs)

### Step 3 - Ask clarifying questions
Work through each section below. Ask only what's missing or unclear - don't re-ask what's already in the files. Group related questions together. Be direct.

**Identity & contact**
- Full name, phone, email, LinkedIn URL, GitHub username

**Experience** (for each role)
- Company, exact job title (as it appeared on contract), start/end month+year
- Key responsibilities - push for specifics: how many clients, how many documents, dollar values, % improvements
- Ask: "What's the most impressive thing you did in this role that isn't obvious from the title?"

**Education**
- Institution, degree, field, graduation year or expected year
- Any relevant coursework, thesis, GPA if strong

**Certifications**
- Name exactly as it appears on the certificate, issuing body, year obtained

**Projects**
- Name, tech stack, what problem it solved, scale (users, data volume, etc.)
- Is it public? GitHub link?
- Ask: "What's one thing about this project that would surprise a technical interviewer?"

**Co-curriculars / leadership**
- Organisation, role title, dates
- What did you actually do - events run, team size, outcomes

**Skills**
- Don't ask for a list - extract from everything above, then ask "anything missing?"

### Step 4 - Ask preference questions
```
~/.claude/resume/preferences.md
```

Ask these if not already answered:
- What roles/industries are off limits? (e.g. no pentesting, no defence)
- Seniority floor/ceiling? (e.g. junior to mid only, no senior)
- Any citizenship/visa constraints to flag?
- Preferred tone for cover letters? (e.g. direct, not corporate, no "I am writing to express my interest")
- Any phrases or patterns to always avoid? (these become a grep check in `tailor-job`, so be literal - exact words, not vibes)
- Any past job title you want presented differently on tailored CVs? (e.g. a title in a field you've said to avoid)
- Base CV length preference (1-page / 2-page)?
- What should be emphasised for each type of role you apply to? (e.g. "for GRC roles lead with the ISO 27001 work, for engineering roles lead with the platform build")
- Working directory for generated applications - e.g. `~/resume-applications/` (see tailor-job's README section on choosing this path; it should NOT be the same repo as this skills repo)

`tailor-job` already enforces a house style on everything it writes: no dashes as
punctuation, no semicolons, no colons outside URLs and standard names, and a long list
of banned AI vocabulary. Don't re-ask about any of that. Record only what the user
wants on top of it, and any place they want it relaxed.

### Step 5 - Write files

Write `profile.md` with this structure:
```markdown
# Career Profile

## Contact
...

## Experience
### [Job Title] - [Company] ([Month Year] - [Month Year])
- ...

## Education
...

## Certifications
...

## Projects
### [Project Name] ([tech stack]) - [dates]
- ...

## Co-curriculars
### [Role] - [Organisation] ([dates])
- ...

## Skills (extracted)
...
```

Write `preferences.md` with this structure:
```markdown
# Application Preferences

## Roles to avoid
...

## Seniority
...

## Visa / work rights
...

## Cover letter tone
...

## Phrases to avoid
...

## Job title reframing
...

## LaTeX conventions
...

## What to emphasise (by role type)
...

## Working directory
~/resume-applications/
```

`tailor-job` reads `## Roles to avoid`, `## Seniority`, `## Phrases to avoid`,
`## Job title reframing` and `## Working directory` by name, so keep those headings
exactly as written even when a section is short. Leave a section out entirely rather
than filling it with placeholder text.

### Step 6 - Confirm
Show the user a summary of what was written. Ask: "Anything to correct or add?"

### A note on privacy
`profile.md` and `preferences.md` contain personal data (name, contact details, work history). Keep `~/.claude/resume/` out of version control, or if you do version it, use a **private** repository. Never commit these files to a public repo.
