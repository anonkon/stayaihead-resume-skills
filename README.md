# StayAIhead Resume Skills

Two [Claude Code](https://claude.com/claude-code) skills that turn "tailor my CV for this job" from a 45-minute manual chore into a single command.

I built these for myself because applying to jobs properly, meaning rewriting a CV and cover letter for every single posting instead of blasting out the same PDF everywhere, was too tedious to do by hand every time. Sharing them in case they're useful to anyone else job hunting.

## What's included

| Skill | Command | What it does |
|---|---|---|
| `build-profile` | `/build-profile` | Interviews you once about your experience, education, certifications, projects, and application preferences. Writes it to `~/.claude/resume/profile.md` and `~/.claude/resume/preferences.md`. |
| `tailor-job` | `/tailor-job` | Takes a pasted job description, reads your profile, and generates a tailored **1-page LaTeX CV** and **cover letter** in a new folder, then compiles both to **PDF**. |

`tailor-job` mirrors the job description's keywords into your CV (without inventing experience you don't have), flags red flags such as seniority mismatch, visa/citizenship requirements, and roles you've said to avoid, and asks before doing anything that touches git.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI
- A LaTeX distribution on your `PATH`, so `pdflatex` resolves:
  - Windows: [MiKTeX](https://miktex.org/)
  - macOS: [MacTeX](https://www.tug.org/mactex/)
  - Linux / WSL: `texlive` (e.g. `sudo apt install texlive-latex-extra`)

## Install

Clone the repo and run the installer for your platform. Both copy the two skills into `~/.claude/skills/`.

**macOS / Linux / WSL / Git Bash:**
```bash
git clone https://github.com/anonkon/stayaihead-resume-skills.git
cd stayaihead-resume-skills
./install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/anonkon/stayaihead-resume-skills.git
cd stayaihead-resume-skills
powershell -ExecutionPolicy Bypass -File install.ps1
```

**Manual install (any OS):** copy `skills/build-profile/` and `skills/tailor-job/` into `~/.claude/skills/`.

## Walkthrough

### 1. Build your profile (once)

```
/build-profile
```

Claude will ask about your experience, education, certifications, and projects, pushing for specifics ("how many clients", "what % improvement") rather than vague bullet points. It'll also ask about application preferences: roles to avoid, seniority range, visa constraints, cover letter tone, and where you want tailored applications saved (e.g. `~/resume-applications/`).

This writes two files:
```
~/.claude/resume/profile.md
~/.claude/resume/preferences.md
```

See [`examples/profile.example.md`](examples/profile.example.md) and [`examples/preferences.example.md`](examples/preferences.example.md) for what these look like (fictional data).

### 2. Tailor a job application

Paste a job description and run:

```
/tailor-job
```

Claude will:
1. Parse the JD for company, role, responsibilities, keywords, and any explicit application questions
2. Ask up to 4 quick clarifying questions (what to emphasise, hiring manager name, etc.)
3. Create `{working_directory}/{Company}_{RoleShort}/`
4. Write a tailored CV and cover letter as LaTeX source
5. Compile both to PDF
6. If the working directory is a git repo, offer to commit (and push, if you confirm)

Output:
```
~/resume-applications/Acme_SoftwareEngineer/
├── Resume_Jordan_Rivera_AcmeSoftwareEngineer.tex
├── Resume_Jordan_Rivera_AcmeSoftwareEngineer.pdf
├── CoverLetter_Jordan_Rivera_AcmeSoftwareEngineer.tex
└── CoverLetter_Jordan_Rivera_AcmeSoftwareEngineer.pdf
```

You'll also get a short report: top matched keywords, any gaps, and flags (e.g. "this role requires citizenship, and you flagged that as a dealbreaker").

## Privacy

`profile.md` and `preferences.md` contain personal data, including your name, contact details, and work history. They're written to `~/.claude/resume/`, which is **outside this repo**, and this repo's `.gitignore` refuses to track a nested `resume/`, `profile.md`, or `preferences.md` as a safety net. Keep that folder out of version control, or use a private repo if you version it.

The `examples/` folder in this repo only ever contains fictional placeholder data. Never copy your real profile into a public repo.

## Customizing

Both skills are just Markdown instruction files. Edit them directly under `~/.claude/skills/build-profile/SKILL.md` and `~/.claude/skills/tailor-job/SKILL.md` (or in `skills/` in this repo before installing) to change formatting rules, section order, tone constraints, or the LaTeX templates.

## How it works

Claude Code skills are Markdown files with YAML frontmatter (`name`, `description`) placed at `~/.claude/skills/<skill-name>/SKILL.md`. Claude Code discovers them automatically and exposes them as `/<skill-name>` commands. There's no build step and no plugin system, just files.

## License

[MIT](LICENSE)
