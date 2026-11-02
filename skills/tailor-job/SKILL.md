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

`preferences.md` is authoritative wherever it disagrees with the defaults in this file. In particular, honour its `## Phrases to avoid`, `## Roles to avoid`, and any job title reframing it specifies (e.g. a past title the user wants presented differently).

## Required no-ai-slop review on every run

After reading the profile and preferences, load the sibling `../no-ai-slop/SKILL.md` and its `eval.md`. This dependency is required on every invocation, including follow-up edits. If it is missing, tell the user to reinstall this repository's skills and stop before generating documents.

Pass both files' full contents to the writing subagent along with the tailoring instructions. Apply no-ai-slop in edit mode to every generated application document, including CV, cover letter, screening answers and supporting notes. The draft, audience and purpose come from this workflow, so do not ask the user to paste a draft again.

Before compiling, review the complete prose against `eval.md`, fix failed checks and repeat until it passes. Repeat this review after any later prose edits, then recompile affected PDFs and rerun the existing verification checks. Preserve confirmed facts, technical names, ATS keywords and the candidate's voice. The user's preferences and this skill's stricter punctuation and document-format rules take precedence where they conflict with no-ai-slop defaults. Keep editorial notes out of application files and include a brief What changed note in the final report.

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

### Scope of the rules below

Everything in this step applies to every document the skill produces, not just the CV
and the cover letter. A prep sheet, an interview notes file, a research summary, a
tracker entry, anything written into the application folder or anywhere else is
covered by the same punctuation, vocabulary and dash rules. The user reads those files
too, and often pastes from them.

### Absolute rule: it must not read as AI-written

The cover letter is the part a human actually reads, and current AI prose has a
recognisable texture. A reader who spots it discounts everything else in the
application. This matters more than any keyword target.

**Punctuation.** No semicolons anywhere, in the cover letter or the CV. A semicolon
reads as machine-written almost every time. Use a full stop. In CV bullets, "Ran 20+
assessments; identified 100+ issues" becomes "Ran 20+ assessments. Identified 100+
issues."

No colons either, anywhere, in the cover letter or the CV. There are exactly three
exceptions, and all three are technical tokens rather than punctuation:
1. Inside a URL, such as `https://` and `mailto:`
2. Inside a standard's canonical name, such as `ISO/IEC 27001:2022`
3. LaTeX syntax that requires one, of which there is normally none

Every other colon gets converted. The concrete conversions:
- A project title with a subtitle takes a comma.
  `\projectheader{Atlas: Compliance \& Risk Platform}{...}`
  becomes
  `\projectheader{Atlas, Compliance \& Risk Platform}{...}`
- A skills category label goes on its own line in bold, with its terms beneath.
  `\textbf{Languages \& Frameworks:} TypeScript, Python, ...`
  becomes
  `\textbf{Languages \& Frameworks}\\` then `TypeScript, Python, ...` on the next line.
  Never a colon after the label, and never a `\textbar{}` separator either.
- The cover letter subject line drops `Re:` entirely.
  `\textbf{Re: QA Engineer}` becomes `\textbf{Application for QA Engineer}`
- A colon introducing a list mid-bullet becomes a full stop and a new sentence.
  "Ran 15+ control gap assessments against ISO 27001: defined the expected outcome,
  tested actual state" becomes "Ran 15+ control gap assessments against ISO 27001.
  Defined the expected outcome, tested actual state"
- A colon doing a dramatic pause is always a full stop. "I built X: it does A, B and
  C" becomes "I built X. It does A, B and C."

**Banned constructions**, because they are AI tells rather than how people write:
- "I sit squarely inside/within", "sits closer still", "squarely"
- "which is precisely why", "that is precisely", "and that is exactly"
- "What I bring alongside that is", "What I do have is", "Here is what I do bring"
- "The transferable part is", "The X part matters too", "the shape of the work"
- "Structurally that is not far from", "is no different from"
- "X is my daily tool, not an occasional one", "daily, and not casually"
- "The hard part is", "second nature", "deliberately built", "a discipline I have built"
- "is the part of the job I do most", "framed around", "which is why I can"
- "Most of that work is the operational side of", "a substantial share of them"
- Any sentence whose whole job is to announce the next sentence

**Banned vocabulary.** These are the individual words and short phrases that language
models overuse. Remove every one and rewrite the sentence in plain words. Do not swap
in a synonym from the same register, which just moves the tell.

Hard banned, case insensitive:

gate, gating, gated, gate sign-off, quality gate, quality gates
from another angle, viewed another way, put another way, seen another way
at scale, structurally, underpin, underpinned, harness (as a verb)
leverage, delve, robust, seamless, seamlessly, streamline, streamlined
cutting-edge, state-of-the-art, best-in-class, world-class, next-generation
holistic, comprehensive, showcase, spearhead, foster, elevate, unlock, empower
navigate (in the figurative sense), realm, landscape, ecosystem, journey, tapestry
testament, pivotal, crucial, crucially, meticulous, meticulously, myriad, plethora
transformative, innovative, dynamic, vibrant, profound, resonate, curated, bespoke
deep dive, actionable insights, key differentiator, bridge the gap, moving the needle
the intersection of, in today's, ever-evolving, rapidly evolving, game-changer
moreover, furthermore, additionally, notably, importantly, it is worth noting
ultimately, that said, synergy, orchestrate (unless it literally means container
orchestration), align and alignment used as a buzzword rather than a real fit

Watch "gate", "from another angle", "at scale" and "structurally" hardest of all.
Those four are the ones that leaked into finished CVs before anyone caught them.

Replacements that keep the meaning without the tell:
- "quality gates" becomes "release sign-off criteria", or just "sign-off"
- "each gate had been met" becomes "each requirement had been met"
- "evidence that a gate has passed" becomes "evidence that a check has passed"
- "gate sign-off" becomes "sign-off"
- "at scale" becomes the actual number, e.g. "across 263 organisations", or "in bulk"
- "structurally a test harness" becomes "which is how a test harness works"
- "quality assurance from another angle" becomes a plain statement of what the work was

Technical terms stay when they are the real name of a thing the candidate built rather
than filler. Evaluation harness, test harness, RAG, GraphRAG, DAG, CI/CD, pipeline,
retrieval, reranking, agentic coding, control testing, audit trail. Judge by whether
the term appears in `profile.md` as something they actually worked on.

**The nominalised-gerund sentence.** This is the single most recognisable AI
construction and it must never appear. It takes a verb phrase, turns it into the
subject of the sentence, and predicates something abstract about it:

> "Turning a regulatory requirement into guidance a delivery team can act on
> without stalling is the part of the job I do most."

Nobody says this out loud. Rewrite with a person doing a thing:

> "Most days the job comes down to taking a regulatory requirement and turning it
> into something a delivery team can actually act on."

Watch for any sentence that opens with an "-ing" phrase and lands on "is the part
of", "is what I do", "is where I add value", "is the skill that transfers".

**Patterns to avoid**, which are subtler than banned words:
- Triads everywhere. Real writing does not put every list in threes.
- Every paragraph opening with a thesis statement then supporting it. Vary it.
- Perfectly balanced sentence pairs, the "not X, but Y" rhythm.
- Abstract nouns doing the work: "the shape of the work", "the underlying discipline".
  Name the actual thing instead.
- Uniform sentence length. Mix a four word sentence in with a twenty five word one.

**What to do instead.** Write the way a competent person types when they are
slightly pressed for time. Concrete nouns. Plain verbs. Say the thing, then stop.
Let one sentence be blunt. It is fine to start a sentence with "And" or "But", and
fine to end a paragraph without a summarising line.

**Check before finishing.** Read the letter aloud in your head. Any sentence you
would not say out loud to a person across a desk gets rewritten or cut.

### Absolute rule: no dashes as punctuation

This rule outranks every style preference below it and applies to the CV, the cover
letter, and any other document produced.

Never emit any of these:
- `---` (LaTeX renders it as an em dash)
- `--` (LaTeX renders it as an en dash)
- The literal em dash and en dash characters (U+2014, U+2013)

Use instead:
- A comma or a full stop where a dash would have joined clauses. Never a colon, which
  is banned in its own right
- The word "to" for every range, as in `Jan.\ 2024 to Present`, `60 to 75\%`,
  `4 to 6 keywords`
- A comma for a title and subtitle, as in `Atlas, AI-Powered Governance Platform`

Two places dashes historically leaked in, so check both explicitly:
1. The `\roleheader` macro definition, which used to contain `--`
2. Comment separator banners. Write them as `%=====`, never `%-----`, so that a
   grep for a dash returns real problems only

Hyphens inside a single word are fine and expected: `AI-driven`, `cross-encoder`,
`proof-of-concept`, `\vspace{-4pt}`, `[10pt, a4paper]`.

Tell the subagent this rule verbatim. Do not paraphrase it into "avoid em-dashes",
which has repeatedly failed.

### CV tailoring rules
- 1-page, `10pt, a4paper`
- Margins `top=0.45in, bottom=0.45in, left=0.65in, right=0.65in`
- Packages `geometry, fontenc, lmodern, inputenc, hyperref, enumitem, titlesec, microtype`
- Use `\usepackage{lmodern}` immediately after `\usepackage[T1]{fontenc}`, required for compilation
- No `tabularx`, no math-mode characters (`$|$`, `$\cdot$`). Use `\textbar{}` in the
  header contact line only, never as a separator in the skills section
- Skills section, plain comma-separated text, no table
- **Fixed section order, two anchors that never move.** The summary is always the
  first section after the header block. The skills section is always the last section
  before `\end{document}`, whatever it happens to be titled (Skills, Technical Skills).
  The sections in between, typically Experience, Certifications, Education and
  Projects, may be reordered and retitled to suit the role (e.g. Education first for a
  graduate program). Reordering never applies to the summary or the skills section.
  Those two are fixed. When moving a section, move the whole block including its
  `%=====` banner comment, the `\section{...}` line and all of its body, so no orphan
  banner or duplicated `\small` is left behind
- Bold the 4 to 6 most ATS-critical keywords in experience bullets
- Mirror exact keywords from the JD throughout, but never fabricate experience,
  skills, or claims not supported by `profile.md`
- ATS target of 90%+ keyword match
- Dates in `Jan.\ 2024` format
- Date ranges use the word "to", never a dash, as in `Jan.\ 2024 to Present` and
  `Feb.\ 2023 to Jan.\ 2024`
- **Skills section layout.** No vertical bars. A bar-separated run-on is hard to read.
  Each category label is bold on its own line, terms on the line below, comma
  separated, `\\[3pt]` between categories and no trailing break after the last:
  ```latex
  \textbf{Governance \& Compliance}\\
  PCI DSS, ISO/IEC 27001:2022, NIST CSF, SOC 2, control evidence\\[3pt]
  \textbf{Risk \& Assurance}\\
  Risk registers, control gap analysis, third-party and vendor risk
  ```
  Keep each category to roughly two rendered lines. This layout costs four extra
  lines over a bar-separated format, so it is usually what tips a dense CV onto a
  second page. When that happens, cut the weakest keywords rather than shrinking the
  spacing
- Project subtitles use a comma, never a colon, as in
  `\projectheader{Atlas, Compliance \& Risk Platform}{...}`

### Cover letter rules
- Format is a `flushright` header (name, phone, email, LinkedIn, date), then the
  recipient block, then the subject line, then the body
- The subject line is `\textbf{Application for {Role Title}}`. Never `\textbf{Re: Role
  Title}`, because `Re:` carries a banned colon. Drop `Re:` entirely
- Use today's actual date
- Length of 4 paragraphs maximum, fits on one page
- Bold 3 to 5 key phrases per letter
- Do NOT use "I am writing to express my interest", "I would welcome the opportunity", "I am passionate about"
- DO answer any explicit JD questions or employer questions within the body naturally
- Tone is direct, specific, human, not corporate
- Close with "Happy to discuss further." or an equivalent short human line
- Sign off with `Yours sincerely,\\[20pt]\textbf{FirstName LastName}`, using the
  candidate's name from `profile.md`
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
\newcommand{\roleheader}[3]{\noindent\textbf{#1}, \textit{#2} \hfill \textit{#3}\par\vspace{1pt}}
\newcommand{\projectheader}[2]{\noindent\textbf{#1} \hfill \textit{#2}\par\vspace{1pt}}
```
Note the comma in `\roleheader`. Do not restore the `--` separator that used to be
here. LaTeX renders `--` as an en dash, which is what kept putting dashes into
finished CVs even when the prose contained none.

`\projectheader` takes a comma between a project name and its subtitle, never a colon.
Write `\projectheader{Atlas, Compliance \& Risk Platform}{...}`. A bold label inside
the skills section takes neither. It sits alone on its own line with its terms on the
line beneath.

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

Confirm each document is exactly one page. Subagents consistently underestimate
length, so expect to trim and recompile rather than trusting their estimate:
```bash
tr -d '\n\r' < "{folder}/{filename}.log" | grep -o 'Output written on[^(]*([0-9]* page'
```

## Step 6b - Verify before finishing (do not skip)

Run these checks on the finished files. Do not report success until all of them pass.

```bash
cd "{folder}"
# 1. Source must contain no dash punctuation at all
grep -n -- '--' *.tex

# 2. Rendered output must contain no em or en dash characters. Needs pdftotext
#    (poppler-utils, or bundled with MiKTeX). If it isn't installed, say so and
#    rely on check 1 rather than silently skipping
for f in *.pdf; do echo "$f: $(pdftotext -enc UTF-8 "$f" - | grep -cP '\x{2014}|\x{2013}')"; done

# 3. Semicolons, in the CV as well as the letter
grep -n ";" *.tex

# 4. Colons, in the CV as well as the letter. Every hit must be one of exactly three
#    allowed technical tokens, a URL (https:// or mailto:), a standard's canonical
#    name (ISO/IEC 27001:2022), or LaTeX syntax that requires one. Anything else,
#    including "Re:", a project subtitle, a skills category label, or a colon
#    introducing a list, is a failure and must be rewritten
grep -n ":" *.tex

# 5. Banned AI vocabulary
grep -in "gate\|from another angle\|viewed another way\|put another way\|at scale\|structurally\|underpin\|leverage\|delve\|robust\|seamless\|streamline\|cutting-edge\|state-of-the-art\|best-in-class\|world-class\|next-generation\|holistic\|comprehensive\|showcase\|spearhead\|foster\|elevate\|unlock\|empower\|realm\|landscape\|ecosystem\|journey\|tapestry\|testament\|pivotal\|crucial\|meticulous\|myriad\|plethora\|transformative\|innovative\|dynamic\|vibrant\|profound\|resonate\|curated\|bespoke\|deep dive\|actionable insights\|key differentiator\|bridge the gap\|moving the needle\|the intersection of\|in today's\|ever-evolving\|rapidly evolving\|game-changer\|moreover\|furthermore\|additionally\|notably\|importantly\|it is worth noting\|ultimately\|that said\|synergy\|orchestrate" *.tex

# 6. AI tell phrases
grep -in "squarely\|precisely why\|what I do have is\|second nature\|not casually\|the hard part is\|here is what I do bring\|is the part of the job\|framed around\|which is why I can" *.tex

# 7. The user's own banned wording. Build this pattern from the
#    "## Phrases to avoid" and "## Roles to avoid" sections of preferences.md,
#    plus any job title the user has asked to have reframed
grep -in "{phrases from preferences.md, pipe separated}" *.tex

# 8. Summary must be the first section in the CV, skills must be the last
grep -n '\\section' Resume*.tex
```

Checks 1, 3, 5, 6 and 7 must all print nothing. Check 2 must report 0 for every PDF.
Check 4 will print the header hyperlinks and any certification standard, and nothing
else. Read every line it returns and confirm each one is a URL, a standard's canonical
name, or required LaTeX syntax. Check 8 must show the summary as the first
`\section` and the skills section as the last, whatever the two are titled. If any
check fails, fix the `.tex` and recompile. Never edit the PDF.

Terms that survive check 5 because they are the real technical name of a thing the
candidate built are listed under the banned vocabulary rule above. An "evaluation
harness" or a "test harness" is a real artefact and stays. "Harness" as a verb does
not.

Then read the cover letter through once, as prose. The greps catch known phrases, but
new AI constructions appear that no grep anticipates. Any sentence you would not say
out loud to a person across a desk gets rewritten.

Then re-read the job description and confirm that nothing in either document claims a
tool, platform, or domain the user has not confirmed having. Fabricated experience is
a worse failure than a formatting slip.

## Step 6c - Clean up build artifacts (do not skip)

`pdflatex` drops an `.aux`, `.log` and `.out` beside every PDF, and more besides for
some documents. The `.log` is needed during Step 6 and Step 6b to confirm the page
count and check for overfull boxes, so delete these only after those checks have
passed, never before.

Delete them from the application folder once verification is done:

```bash
cd "{folder}"
rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz *.dvi \
      *.bbl *.blg *.bcf *.run.xml *.nav *.snm *.vrb
```

Then confirm only the four deliverables remain, two `.tex` and two `.pdf`:

```bash
ls "{folder}"
```

A `.gitignore` that covers these extensions is not a reason to leave them on disk.
They accumulate across every application folder and clutter the working tree.

If a recompile is needed after this step, rerun the cleanup afterwards.

## Step 7 - Git commit (optional, ask first)

Only do this if the working directory is already inside a git repository (check with `git rev-parse --is-inside-work-tree`). If it isn't, skip this step and tell the user the files are ready in the folder.

If it is a git repo, **ask the user before pushing** - don't push automatically:
```bash
git add "{Company}_{RoleShort}/"
git commit -m "Add application: {Role} at {Company}"
```
Only run `git push` after the user explicitly confirms.

Afterwards, check that `git status` is clean for the application folder. If a build
artifact shows up as untracked, the repo's `.gitignore` has drifted, so add the
extension there rather than deleting the file and moving on.

## Step 8 - Report to user

Tell the user:
- Folder created: `{Company}_{RoleShort}/`
- Files: CV `.tex` + `.pdf`, cover letter `.tex` + `.pdf`
- Estimated ATS match: list top 5 matched keywords, flag any gaps
- Any red flags or notes about the role (visa, seniority, etc.)
- How to apply (if known from JD)
