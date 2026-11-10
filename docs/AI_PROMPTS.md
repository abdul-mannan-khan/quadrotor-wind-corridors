# Prompts for working with an AI assistant

An AI assistant (a chat or coding assistant) can save you a lot of time on this project: finding papers, writing
search strings, setting up runs on Vast.ai, reading results and checking your writing. It can also be confidently
wrong. Use these prompts as starting points, and keep the rules at the end in mind.

Replace the parts in `<angle brackets>`. Give the assistant the context it needs (paste the relevant README section,
a config file or a results table): it does not know this repository unless you show it.

---

## 1. Literature search in IEEE Xplore and Scopus

Your university gives you access to **IEEE Xplore** (<https://ieeexplore.ieee.org>) and **Scopus**
(<https://www.scopus.com>). Log in through the library. The assistant cannot log in for you; it writes the
searches, you run them, and you paste the results back.

**Build the search strings**

```text
I am writing an M.Sc. dissertation on quadrotor parcel delivery through urban wind corridors: path planning
that uses a street-level wind map, energy per delivery, and refusing flights whose required tilt is too high.
Write search strings for IEEE Xplore (Command Search syntax) and for Scopus (TITLE-ABS-KEY syntax) for these
topics, one string per topic:
 (a) UAV / drone path planning in urban wind fields (CFD, LES or wind maps)
 (b) energy consumption models of multirotor delivery drones
 (c) safety or feasibility checks for drone delivery in strong wind (control authority, tilt, gusts)
 (d) <your own topic>
Limit to 2020-2026, journal and conference papers in English. For each string, say which synonyms you
included and why, and estimate whether it will return too many or too few results.
```

**Narrow or widen after the first run**

```text
Search (b) gave <N> results in Scopus. Here are the first 20 titles: <paste>. Most are about <off-topic
area>. Rewrite the string to exclude that, keep the relevant ones, and explain each change.
```

**Screen the results**

```text
Here are <N> results (title, year, venue, abstract) exported from <IEEE Xplore / Scopus>: <paste or attach CSV>.
Sort them into: highly relevant / partly relevant / not relevant to <your research question>. For each highly
relevant paper give one sentence on what it does and one on how it differs from my work. Do not add papers
that are not in my list.
```

**Make a comparison table for the literature review**

```text
From these <N> papers (abstracts below), make a table with columns: paper, wind model (none / uniform / CFD /
LES / measured), what is optimised (route, height, speed), energy model, safety check, real city geometry
(yes/no), validation (simulation / hardware). Mark a cell "not stated" if the abstract does not say it.
```

**Check novelty**

```text
My contribution is: <one or two sentences>. Here are the 10 closest papers I found (title + abstract): <paste>.
Which of them, if any, already does this? Be specific and quote the sentence of the abstract that shows it.
Then suggest two more search strings that would find a paper doing exactly my contribution, so I can check.
```

Export results from IEEE Xplore (**Export → CSV**) or Scopus (**Export → CSV**, with abstracts) and keep the files
with the date of the search: you need the date, the database and the exact string in your methods chapter.

---

## 2. Running simulations on a Vast.ai machine

Read [VAST_AI_GUIDE.md](VAST_AI_GUIDE.md) first (and [CITY_WINE.md](CITY_WINE.md) for the city map).

**Plan a run and its cost**

```text
I want to run this experiment from the quadrotor-wind-corridors repository: <paste the YAML config>.
It flies <N> missions; one mission takes about <t> CPU-seconds (measured with configs/quick.yaml).
How many CPU cores should I rent, about how long will it take, and what will it cost at $<price>/h?
Remind me what to download before I destroy the machine.
```

**Write a new experiment file**

```text
Here is configs/template_all_options.yaml from my repository: <paste>. Write a config named <name> that
compares the planners shortest, energy0 and wind for parcel masses 0.3, 0.6 and 1.0 kg at wind speeds 8, 12
and 16 m/s, all eight wind directions, customer 0, controller dob, seeds 0 and 1. Tell me how many missions
it has and how to run it.
```

**Rent and use a machine from the command line (optional)**

```text
Using the Vast.ai command-line client (vastai), give me the commands to: find a machine with 1 GPU of 8 GB or
more, NVIDIA driver 595 or newer, 16+ CPU cores, reliability above 98 %, sorted by price; rent it with the image
abdulmannan617/quadrotor-wind-corridors:<latest or city-wine>, 60 GB disk and the Docker options
"-e NVIDIA_DRIVER_CAPABILITIES=all -e NVIDIA_VISIBLE_DEVICES=all"; connect by SSH; start my experiment inside
tmux; copy results/experiments/<name>/ back to my laptop with scp; and destroy the machine. Explain each command.
```

**When something fails**

```text
On the Vast.ai machine, this command: <command> printed this error: <paste the last 30 lines>. The machine has
<GPU, driver, cores>. What is the most likely cause and what should I try first? If the fix is "rent another
machine", say so.
```

**Never leave a machine running.** Ask the assistant: *"What must I download before I destroy the machine?"*, then
destroy it in the Vast.ai **Instances** page.

---

## 3. Understanding the code and the results

```text
Here is sim/<file>.py from my repository: <paste>. Explain what the function <name> does, step by step, in plain
English, and which equations of the dissertation it implements. Point out any assumption I should state in my
methods chapter.
```

```text
Here is the summary table of my experiment (from summarise.py): <paste>. What are the three main findings?
Which differences are within the noise (give me the test or confidence interval to check), and what would a
critical examiner ask about them?
```

```text
I changed <parameter> from <a> to <b> and the result changed from <x> to <y>. List possible explanations,
and for each one a small experiment (a config) that would tell them apart.
```

---

## 4. Writing

```text
Here is a paragraph of my <chapter>: <paste>. Make it clearer and shorter: sentences of about 15-20 words, plain
words, no new claims. Keep every number and citation exactly as it is. Then list anything that sounds stronger
than my results support.
```

```text
Check this results section against this table: <paste both>. List every number in the text that does not match
the table.
```

---

## Rules for using an AI assistant

1. **Check every reference yourself** in IEEE Xplore, Scopus or the publisher's page. Assistants sometimes invent
   papers, authors or DOIs that look real.
2. **Check every number** against your own results files. The assistant does not run your code unless you run it.
3. **Never paste passwords, API keys or access tokens** into a prompt, and never put them in this repository.
4. **Follow your university's rules on AI use** and say in your dissertation how you used AI tools (UWL asks for
   this). The ideas, the analysis and the final text are your responsibility.
5. **Keep the search dates and strings** for your methods chapter.
6. **Destroy cloud machines** when you finish; ask the assistant to remind you.
