#!/usr/bin/env node

"use strict";

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const PROJECT_DIR = path.resolve(__dirname, "..");
const PLACEHOLDER = "__AGENT_USER_PLACEHOLDER__";

function parseArgs() {
  const args = process.argv.slice(2);
  let agentFile = null;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--agent-file" && args[i + 1]) {
      agentFile = args[i + 1];
      i++;
    }
  }

  if (!agentFile) {
    console.error("Error: --agent-file parameter is required");
    console.error("Usage: setup-service-agent.js --agent-file <path>");
    process.exit(1);
  }

  return { agentFile };
}

function validateAgentFile(filePath) {
  const resolvedPath = path.isAbsolute(filePath) ? filePath : path.resolve(PROJECT_DIR, filePath);

  if (!fs.existsSync(resolvedPath)) {
    console.error(`Error: Agent file not found: ${resolvedPath}`);
    process.exit(1);
  }

  if (!resolvedPath.endsWith(".agent")) {
    console.error(`Error: File must have .agent extension: ${resolvedPath}`);
    process.exit(1);
  }

  return resolvedPath;
}

function log(msg) {
  process.stderr.write(msg + "\n");
}

function createAgentUser() {
  const cmd = "sf org create agent-user --json";

  log(`Running: ${cmd}`);

  try {
    const output = execSync(cmd, {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"]
    });
    const result = JSON.parse(output);

    if (result.status !== 0) {
      console.error("Failed to create agent user:", result.message);
      process.exit(1);
    }

    return result.result.username;
  } catch (error) {
    console.error("Error creating agent user:", error.message);
    process.exit(1);
  }
}

function replacePlaceholders(username, agentFilePath) {
  let content = fs.readFileSync(agentFilePath, "utf8");

  if (!content.includes(PLACEHOLDER)) {
    log(`Warning: File does not contain the placeholder "${PLACEHOLDER}". It may have already been replaced.`);
  } else {
    content = content.replace(PLACEHOLDER, username);
    fs.writeFileSync(agentFilePath, content, "utf8");
    log(`Updated: ${path.basename(agentFilePath)}`);
    log(`\nReplaced placeholder with agent user: ${username}`);
    log("\nReminder: The pre-commit hook will restore the placeholder automatically.");
  }
}

const { agentFile } = parseArgs();
const agentFilePath = validateAgentFile(agentFile);
const username = createAgentUser();
replacePlaceholders(username, agentFilePath);

process.stdout.write(username);
