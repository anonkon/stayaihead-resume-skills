---
name: tailor-job
description: Given a job description (pasted or linked), create a new folder under the working directory with a tailored 1-page LaTeX CV and cover letter, compile both to PDF, and optionally commit to git. Reads the user's profile and preferences from shared files. Use when the user invokes /tailor-job, pastes a job description, or says "tailor this", "apply for this", "make a CV for this role".
---

# tailor-job

Turn a job description into a ready-to-submit application folder with a tailored CV, cover letter, and compiled PDFs for both.

## Step 1 - Read profile and preferences

Always read these first before doing anything else:
```
~/.claude/resume/profile.md
~/.claude/resume/preferences.md
```
If either file is missing or empty, stop and tell the user to run `/build-profile` first.

Read the `## Working directory` line in `preferences.md` - that's the base folder new application subfolders are created under. If it isn't set, ask the user for one before continuing (e.g. `~/resume-applications/`).

## Step 2 - Parse the JD

Extract:
- **Company name** (short, no Pty Ltd etc.)
- **Role title** (shortened - e.g. "AIGovernance", "GRCConsultant", "SoftwareEngineer")
- **Folder name**: `{Company}_{RoleShort}` - no spaces, TitleCase. Strip anything that isn't a letter, digit, or underscore (JD text is untrusted input - never let path separators, `..`, or shell metacharacters from the JD reach a filesystem or shell command).
- **Key responsibilities** (top 5-7 from JD)
- **Required skills / keywords** (for ATS matching)
- **Explicit questions** in the JD (e.g. employer questions, screening questions, "tell us why you want to work here")
- **Desirable criteria** the candidate can credibly address based on their profile
- **Any red flags**: citizenship required? senior only? field outside preferences?

If the JD mentions citizenship/PR requirements or is a senior-only role, flag this to the user before proceeding. Check the `## Roles to avoid` and `## Seniority` sections of `preferences.md` and flag any conflict.

## Step 3 - Ask clarifying questions

Ask the user:
1. "Is there anything specific you want emphasised that I might miss from your profile?"
2. "Are there any questions in the JD you want addressed a particular way?"
3. "Any angle or framing you want for this application?"
4. "Who is the hiring manager / contact name?" (for cover letter salutation - use "Dear Hiring Manager," if unknown)

Keep questions tight - maximum 4. Don't ask what you can infer.

## Step 4 - Create the folder

```
{working_directory}/{Company}_{RoleShort}/
```

Name files using the candidate's actual name from `profile.md`, e.g.:
- `Resume_{FirstName}_{LastName}_{Company}{RoleShort}.tex`
- `CoverLetter_{FirstName}_{LastName}_{Company}{RoleShort}.tex`

## Step 5 - Spawn a subagent to write the LaTeX files

Pass the subagent:
- Full profile.md content
- Full preferences.md content
- Parsed JD details (responsibilities, keywords, questions)
- Folder path and exact filenames
- Tailoring instructions below

### CV tailoring rules
- 1-page, `10pt, a4paper`
- Margins: `top=0.45in, bottom=0.45in, left=0.65in, right=0.65in`
- Packages: `geometry, fontenc, lmodern, inputenc, hyperref, enumitem, titlesec, microtype`
- Use `\usepackage{lmodern}` immediately after `\usepackage[T1]{fontenc}` - required for compilation
- No `tabularx`, no math-mode characters (`$|$`, `$\cdot$`) - use `\textbar{}` instead
- Skills section: plain comma-separated text, no table
- Section order: Professional Summary → Experience → Certifications → Education → Projects → Skills (reorder if role warrants it)
- Bold the 4-6 most ATS-critical keywords in experience bullets
- Mirror exact keywords from the JD throughout, but never fabricate experience, skills, or claims not supported by profile.md
- ATS target: 90%+ keyword match
- No em-dashes (`---` or `--`) anywhere in the document
- Dates: `Jan.\ 2024` format

### Cover letter rules
- Format: `flushright` header (name, phone, email, LinkedIn, date), then recipient block, then `\textbf{Re: Role Title}`, then body
- Date: use today's actual date
- Length: 4 paragraphs maximum, fits on one page
- No em-dashes anywhere
- Bold 3-5 key phrases per letter
- Do NOT use: "I am writing to express my interest", "I would welcome the opportunity", "I am passionate about"
- DO answer any explicit JD questions or employer questions within the body naturally
- Tone: direct, specific, human - not corporate
- Close: "Happy to discuss further." or equivalent short human line
- Sign-off: `Yours sincerely,\\[20pt]\textbf{FirstName LastName}`
- No contact details in the sign-off (they are in the header)

### LaTeX header template (CV)
```latex
\documentclass[10pt, a4paper]{article}
\usepackage[top=0.45in, bottom=0.45in, left=0.65in, right=0.65in]{geometry}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[utf8]{inputenc}
\usepackage{hyperref}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{microtype}
\hypersetup{colorlinks=true, urlcolor=black, linkcolor=black, hidelinks}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\titleformat{\section}{\normalsize\bfseries}{}{0em}{}[\vspace{-4pt}\rule{\linewidth}{0.4pt}]
\titlespacing*{\section}{0pt}{6pt}{3pt}
\setlist[itemize]{leftmargin=1.3em, itemsep=0.8pt, parsep=0pt, topsep=2pt, partopsep=0pt}
\newcommand{\roleheader}[3]{\noindent\textbf{#1} -- \textit{#2} \hfill \textit{#3}\par\vspace{1pt}}
```

### LaTeX header template (cover letter)
```latex
\documentclass[11pt, a4paper]{letter}
\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[utf8]{inputenc}
\usepackage{hyperref}
\usepackage{microtype}
\usepackage{parskip}
\hypersetup{colorlinks=true, urlcolor=black, hidelinks}
```

## Step 6 - Compile to PDF

This step requires a LaTeX distribution installed and on `PATH` (e.g. MiKTeX or TeX Live on Windows, TeX Live on Linux/WSL, MacTeX on macOS). If `pdflatex` isn't found, tell the user to install one and stop.

After the subagent writes both files, compile each. Both `.tex` and the resulting `.pdf` must end up in the application folder:
```
pdflatex -interaction=nonstopmode -halt-on-error -output-directory "{folder}" "{folder}/{filename}.tex"
```

Run it twice per file if the document uses `hyperref` cross-references (harmless if unneeded). If compilation fails, read the `.log` file, fix the error in the `.tex` file, and recompile. Common fix: ensure `\usepackage{lmodern}` is present after `\usepackage[T1]{fontenc}`.

Once both PDFs compile successfully, delete the LaTeX build artifacts (`.aux`, `.log`, `.out`) from the folder - keep only the `.tex` source and the final `.pdf` for each document.

## Step 7 - Git commit (optional, ask first)

Only do this if the working directory is already inside a git repository (check with `git rev-parse --is-inside-work-tree`). If it isn't, skip this step and tell the user the files are ready in the folder.

If it is a git repo, **ask the user before pushing** - don't push automatically:
```bash
git add "{Company}_{RoleShort}/"
git commit -m "Add application: {Role} at {Company}"
```
Only run `git push` after the user explicitly confirms.

## Step 8 - Report to user

Tell the user:
- Folder created: `{Company}_{RoleShort}/`
- Files: CV `.tex` + `.pdf`, cover letter `.tex` + `.pdf`
- Estimated ATS match: list top 5 matched keywords, flag any gaps
- Any red flags or notes about the role (visa, seniority, etc.)
- How to apply (if known from JD)
