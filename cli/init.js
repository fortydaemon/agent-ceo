#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: process.stdin.isTTY === true,
});

// Line queue instead of rl.question(): rl.question() drops buffered lines when
// answers are piped in (e.g. `printf '...' | node cli/init.js`), which made the
// CLI exit 0 having created nothing.
const pendingLines = [];
const waiters = [];
let inputClosed = false;
rl.on('line', (line) => {
  if (waiters.length) waiters.shift()(line);
  else pendingLines.push(line);
});
rl.on('close', () => {
  inputClosed = true;
  while (waiters.length) waiters.shift()(null);
});

function readLine(promptText) {
  process.stdout.write(promptText);
  if (pendingLines.length) return Promise.resolve(pendingLines.shift());
  if (inputClosed) return Promise.resolve(null);
  return new Promise((resolve) => waiters.push(resolve));
}

// Echo piped answers so the transcript is readable
function echo(answer) {
  if (!process.stdin.isTTY) console.log(answer === null ? '' : answer);
}

async function ask(question, defaultValue) {
  const suffix = defaultValue ? ` (${defaultValue})` : '';
  const answer = await readLine(`${question}${suffix}: `);
  echo(answer);
  if (answer === null) return defaultValue || '';
  return answer.trim() || defaultValue || '';
}

async function askRequired(question) {
  for (;;) {
    const answer = await readLine(`${question}: `);
    echo(answer);
    if (answer === null) {
      console.error(`Error: input ended before "${question}" was answered.`);
      process.exit(1);
    }
    if (answer.trim()) return answer.trim();
    console.log('  This field is required.');
  }
}

async function askChoice(question, choices, defaultValue) {
  const choiceStr = choices
    .map((c) => (c === defaultValue ? `[${c}]` : c))
    .join(' / ');
  for (;;) {
    const answer = await readLine(`${question} (${choiceStr}): `);
    echo(answer);
    if (answer === null) return defaultValue;
    const value = answer.trim() || defaultValue;
    const match = choices.find((c) => c.toLowerCase() === value.toLowerCase());
    if (match) return match;
    console.log(`  Please choose one of: ${choices.join(', ')}`);
  }
}

function localDate() {
  // toISOString() is UTC, which yields tomorrow's date in the evening in the Americas
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function readTemplate(relativePath, description) {
  const templateDir = path.join(__dirname, '..');
  const fullPath = path.join(templateDir, relativePath);
  try {
    return fs.readFileSync(fullPath, 'utf-8');
  } catch (err) {
    console.error(`  WARNING: Could not read template ${relativePath} (${description})`);
    console.error(`  Expected at: ${fullPath}`);
    return null;
  }
}

function replaceBrackets(content, replacements) {
  let result = content;
  for (const [placeholder, value] of Object.entries(replacements)) {
    result = result.split(placeholder).join(value);
  }
  return result;
}

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function writeFile(filePath, content) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content, 'utf-8');
}

function writeGitkeep(dirPath) {
  ensureDir(dirPath);
  const keepPath = path.join(dirPath, '.gitkeep');
  if (!fs.existsSync(keepPath)) {
    fs.writeFileSync(keepPath, '', 'utf-8');
  }
}

async function main() {
  console.log('');
  console.log('Agent CEO — Project Initializer');
  console.log('================================');
  console.log('');

  const agentName = await ask('Agent name', 'Agent');
  const agentRole = await ask('Agent role', 'CEO');
  const mission = await askRequired('Mission (required)');
  const stakeholder = await ask('Stakeholder name', 'Investor');
  const budget = await ask('Budget amount', '$500');
  const threshold = await ask('Budget threshold for approval', '$100');
  const channel = await askChoice(
    'Communication channel',
    ['Slack', 'Email', 'GitHub Issues'],
    'Slack'
  );
  const outputDir = await ask('Output directory', path.join(process.cwd(), 'my-agent'));

  rl.close();

  console.log('');
  console.log('Creating files...');

  const resolvedOutput = path.resolve(outputDir);

  // Never scaffold over an existing project (or over this framework repo itself)
  const existing = ['AGENT.md', 'agent-progress.txt', 'lessons-learned.md']
    .filter((f) => fs.existsSync(path.join(resolvedOutput, f)));
  if (existing.length || resolvedOutput === path.resolve(__dirname, '..')) {
    console.error(`  Refusing to overwrite: ${resolvedOutput}`);
    if (existing.length) console.error(`  Already contains: ${existing.join(', ')}`);
    console.error('  Choose an empty or new output directory.');
    process.exit(1);
  }

  // Strip dollar signs for numeric placeholders
  const budgetNum = budget.replace(/^\$/, '');
  const thresholdNum = threshold.replace(/^\$/, '');

  // AGENT.md
  const agentMd = readTemplate('templates/AGENT.md', 'AGENT.md template');
  if (agentMd) {
    const replaced = replaceBrackets(agentMd, {
      '[DESCRIBE YOUR AGENT\'S MISSION IN 1-2 SENTENCES]': mission,
      '[AGENT NAME]': agentName,
      '[ROLE]': agentRole,
      '[TIME PERIOD]': '2 weeks',
      '[AMOUNT]': budgetNum,
      '[THRESHOLD]': thresholdNum,
      '[STAKEHOLDER]': stakeholder,
      '[BUDGET FILE PATH]': 'finances/budget.md',
      '[DECISIONS DIRECTORY]': 'decisions/',
      '[REPORTS DIRECTORY]': 'daily-reports',
      '[TOOL 1]': '[TODO: Add your first tool]',
      '[TOOL 2]': '[TODO: Add your second tool]',
      '[TOOL 3]': '[TODO: Add your third tool]',
      '[COMMUNICATION CHANNEL]': channel,
      '[Slack / Email / GitHub Issues / etc.]': channel,
      '[LIST ACCESS METHODS]': 'repo and communication',
      '[PROGRESS FILE]': 'agent-progress.txt',
      '[LESSONS LEARNED FILE]': 'lessons-learned.md',
      '[DATE]': localDate(),
      '[DIRECTIVE]': '[none yet]',
    });
    writeFile(path.join(resolvedOutput, 'AGENT.md'), replaced);
    console.log('  AGENT.md');
  }

  // agent-progress.txt
  const progressTxt = readTemplate('templates/progress.txt', 'progress template');
  if (progressTxt) {
    const today = localDate();
    const replaced = replaceBrackets(progressTxt, {
      // Specific budget lines first, before the generic [AMOUNT] replacement
      'Spent: $[AMOUNT]': 'Spent: $0',
      'Remaining: $[AMOUNT]': `Remaining: $${budgetNum}`,
      '[DATE]': today,
      '[N]': '1',
      '[PHASE NAME]': 'DISCOVER',
      '[Bullet points of what was accomplished]': 'Initial setup',
      '[Include any decisions made and why]': 'Initialized agent project',
      '[Initiative 1]': mission,
      '[DISCOVER / VALIDATE / BUILD / GROW]': 'DISCOVER',
      "[What's done]": 'Project scaffolded',
      '[What needs to happen next]': 'Begin discovery phase',
      '[Any blockers, or "none"]': 'none',
      '[Initiative 2]': '[TODO: second initiative, or delete this section]',
      '[Tool/Service 1]': '[TODO]',
      '[State]': '[TODO]',
      '[Tool/Service 2]': '[TODO]',
      '[AMOUNT]': budgetNum,
      '[Most important thing to do next session]': 'Customize AGENT.md with specific tools and workflows',
      '[Second priority]': 'Begin discovery research',
      '[Third priority]': 'Set up communication channel',
      '[DIRECTIVE]': '[none yet]',
      '[Description]': '[none yet]',
    });
    writeFile(path.join(resolvedOutput, 'agent-progress.txt'), replaced);
    console.log('  agent-progress.txt');
  }

  // lessons-learned.md
  const lessonsLearned = readTemplate('templates/lessons-learned.md', 'lessons-learned template');
  if (lessonsLearned) {
    writeFile(path.join(resolvedOutput, 'lessons-learned.md'), lessonsLearned);
    console.log('  lessons-learned.md');
  }

  // Directory stubs
  writeGitkeep(path.join(resolvedOutput, 'daily-reports'));
  console.log('  daily-reports/.gitkeep');
  writeGitkeep(path.join(resolvedOutput, 'decisions'));
  console.log('  decisions/.gitkeep');
  writeGitkeep(path.join(resolvedOutput, 'logs'));
  console.log('  logs/.gitkeep');

  // scripts/ — they locate the project root from their own path, so no edits needed
  const scripts = ['run-agent.sh', 'start-agent.sh', 'health-check.sh', 'notify-slack.sh', 'watch-slack.sh'];
  for (const script of scripts) {
    const content = readTemplate(`scripts/${script}`, script);
    if (content) {
      const scriptPath = path.join(resolvedOutput, 'scripts', script);
      writeFile(scriptPath, content);
      fs.chmodSync(scriptPath, 0o755);
      console.log(`  scripts/${script}`);
    }
  }

  // .gitignore
  const gitignore = readTemplate('.gitignore', '.gitignore');
  if (gitignore) {
    writeFile(path.join(resolvedOutput, '.gitignore'), gitignore);
    console.log('  .gitignore');
  }

  // Summary
  console.log('');
  console.log('Agent CEO initialized!');
  console.log('');
  console.log('Created:');
  console.log('  AGENT.md              — Operating instructions (customize this)');
  console.log('  agent-progress.txt    — Cross-session memory');
  console.log('  lessons-learned.md    — Institutional memory');
  console.log('  scripts/              — Launcher, restart loop, health check, Slack helpers');
  console.log('');
  console.log('Next steps:');
  console.log(`  1. cd ${resolvedOutput}`);
  console.log('  2. Edit AGENT.md: fill in the [TODO] tools and any remaining [BRACKETS]');
  console.log('  3. git init && git add -A && git commit -m "Initial agent setup"');
  console.log('  4. ./scripts/start-agent.sh   (needs tmux and the claude CLI)');
  console.log('');
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
