#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function ask(question, defaultValue) {
  return new Promise((resolve) => {
    const suffix = defaultValue ? ` (${defaultValue})` : '';
    rl.question(`${question}${suffix}: `, (answer) => {
      const value = answer.trim() || defaultValue || '';
      resolve(value);
    });
  });
}

function askRequired(question) {
  return new Promise((resolve) => {
    const prompt = () => {
      rl.question(`${question}: `, (answer) => {
        const value = answer.trim();
        if (!value) {
          console.log('  This field is required.');
          prompt();
        } else {
          resolve(value);
        }
      });
    };
    prompt();
  });
}

function askChoice(question, choices, defaultValue) {
  return new Promise((resolve) => {
    const choiceStr = choices
      .map((c) => (c === defaultValue ? `[${c}]` : c))
      .join(' / ');
    const prompt = () => {
      rl.question(`${question} (${choiceStr}): `, (answer) => {
        const value = answer.trim() || defaultValue;
        if (!choices.includes(value)) {
          console.log(`  Please choose one of: ${choices.join(', ')}`);
          prompt();
        } else {
          resolve(value);
        }
      });
    };
    prompt();
  });
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
  const outputDir = await ask('Output directory', process.cwd());

  rl.close();

  console.log('');
  console.log('Creating files...');

  const resolvedOutput = path.resolve(outputDir);

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
      '[LIST ACCESS METHODS]': 'repo and communication',
      '[PROGRESS FILE]': 'agent-progress.txt',
      '[LESSONS LEARNED FILE]': 'lessons-learned.md',
      '[DATE]': new Date().toISOString().split('T')[0],
      '[DIRECTIVE]': '[none yet]',
    });
    writeFile(path.join(resolvedOutput, 'AGENT.md'), replaced);
    console.log('  AGENT.md');
  }

  // agent-progress.txt
  const progressTxt = readTemplate('templates/progress.txt', 'progress template');
  if (progressTxt) {
    const today = new Date().toISOString().split('T')[0];
    const replaced = replaceBrackets(progressTxt, {
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
      '[Initiative 2]': '',
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

  // scripts/run-agent.sh
  const runAgent = readTemplate('scripts/run-agent.sh', 'run-agent.sh');
  if (runAgent) {
    const replaced = runAgent.replace(
      /REPO_DIR=~\/dev\/your-project/g,
      `REPO_DIR=${resolvedOutput}`
    );
    const scriptPath = path.join(resolvedOutput, 'scripts', 'run-agent.sh');
    writeFile(scriptPath, replaced);
    console.log('  scripts/run-agent.sh');
  }

  // scripts/start-agent.sh
  const startAgent = readTemplate('scripts/start-agent.sh', 'start-agent.sh');
  if (startAgent) {
    const replaced = startAgent.replace(
      /REPO_DIR=~\/dev\/your-project/g,
      `REPO_DIR=${resolvedOutput}`
    );
    const scriptPath = path.join(resolvedOutput, 'scripts', 'start-agent.sh');
    writeFile(scriptPath, replaced);
    console.log('  scripts/start-agent.sh');
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
  console.log('  AGENT.md              \u2014 Operating instructions (customize this)');
  console.log('  agent-progress.txt    \u2014 Cross-session memory');
  console.log('  lessons-learned.md    \u2014 Institutional memory');
  console.log('  scripts/run-agent.sh  \u2014 Session launcher');
  console.log('  scripts/start-agent.sh \u2014 Auto-restart wrapper');
  console.log('');
  console.log('Next steps:');
  console.log('  1. Edit AGENT.md with your specific tools and workflows');
  console.log('  2. chmod +x scripts/*.sh');
  console.log('  3. ./scripts/start-agent.sh to launch');
  console.log('');
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
