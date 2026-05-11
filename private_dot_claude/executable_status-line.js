#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { execSync } = require('child_process');

// モデル名からコンテキストウィンドウサイズを判定
function getContextWindowSize(modelName) {
  const name = (modelName || '').toLowerCase();
  if (name.includes("1m")) return 1000000;
  if (name.includes("opus")) return 200000;
  if (name.includes("sonnet")) return 200000;
  if (name.includes("haiku")) return 200000;
  return 200000; // デフォルト
}


let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', async () => {
  try {
    const data = JSON.parse(input);

    const model = data.model?.display_name || 'Unknown';
    const contextWindowSize = getContextWindowSize(model);
    const compactionThreshold = contextWindowSize * 0.8;
    const currentDir = path.basename(data.workspace?.current_dir || data.cwd || '.');
    const sessionId = data.session_id;
    // stdin入力JSONからセッション累計コスト(USD)を取得。未定義なら0扱い
    const totalCostUsd = data.cost?.total_cost_usd ?? 0;


    let gitBaranch = '';
    try {
        gitBaranch = execSync("git branch --show-current 2>/dev/null", { encoding: 'utf8', cwd: data.workspace?.current_dir || data.cwd || "." }).trim();
    } catch (e) {
        // Gitリポジトリではない場合は空のまま
    }

    let totalTokens = 0;

    if (sessionId) {
      const projectsDir = path.join(process.env.HOME, '.claude', 'projects');

      if (fs.existsSync(projectsDir)) {
        // Get all project directories
        const projectDirs = fs.readdirSync(projectsDir)
          .map(dir => path.join(projectsDir, dir))
          .filter(dir => fs.statSync(dir).isDirectory());

        // Search for the current session's transcript file
        for (const projectDir of projectDirs) {
          const transcriptFile = path.join(projectDir, `${sessionId}.jsonl`);

          if (fs.existsSync(transcriptFile)) {
            totalTokens = await calculateTokensFromTranscript(transcriptFile);
            break;
          }
        }
      }
    }

    // Calculate percentage
    const percentage = Math.min(100, Math.round((totalTokens / compactionThreshold) * 100));

    // Format token display
    const tokenDisplay = formatTokenCount(totalTokens);

    // Color coding for percentage
    let percentageColor = '\x1b[32m'; // Green
    if (percentage >= 70) percentageColor = '\x1b[33m'; // Yellow
    if (percentage >= 90) percentageColor = '\x1b[31m'; // Red

    // Build status line
    const branchDisplay = gitBaranch ? `🍃 (${gitBaranch})` : '';
    const costDisplay = formatCost(totalCostUsd);
    const statusLine = `[${model}] 📁 ${currentDir}${branchDisplay} | 🏰 ${tokenDisplay} | ${percentageColor}${percentage}%\x1b[0m | 💰 ${costDisplay}`;

    console.log(statusLine);
  } catch (error) {
    // Fallback status line on error
    console.log('[Error] 📁 . | 🏰 0 | 0% | 💰 $0.00');
  }
});

async function calculateTokensFromTranscript(filePath) {
  return new Promise((resolve, reject) => {
    let lastUsage = null;

    const fileStream = fs.createReadStream(filePath);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });

    rl.on('line', (line) => {
      try {
        const entry = JSON.parse(line);

        // Check if this is an assistant message with usage data
        if (entry.type === 'assistant' && entry.message?.usage) {
          lastUsage = entry.message.usage;
        }
      } catch (e) {
        // Skip invalid JSON lines
      }
    });

    rl.on('close', () => {
      if (lastUsage) {
        // The last usage entry contains cumulative tokens
        const totalTokens = (lastUsage.input_tokens || 0) +
          (lastUsage.output_tokens || 0) +
          (lastUsage.cache_creation_input_tokens || 0) +
          (lastUsage.cache_read_input_tokens || 0);
        resolve(totalTokens);
      } else {
        resolve(0);
      }
    });

    rl.on('error', (err) => {
      reject(err);
    });
  });
}

function formatTokenCount(tokens) {
  if (tokens >= 1000000) {
    return `${(tokens / 1000000).toFixed(1)}M`;
  } else if (tokens >= 1000) {
    return `${(tokens / 1000).toFixed(1)}K`;
  }
  return tokens.toString();
}

// セッション累計コスト(USD)を $0.12 形式の文字列に整形
function formatCost(usd) {
  return `$${usd.toFixed(2)}`;
}
