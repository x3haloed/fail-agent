use crate::{llm::LlmClient, state::StateManager, cost::CostPressure};
use async_trait::async_trait;
use anyhow::Result;
use std::process::Command;
use tracing::{info, warn};

#[derive(Debug, Clone)]
pub enum AgentType {
    ExecutionVerification,
    CodeSlop,
    Architecture,
    UiSnob,
}

#[derive(Debug)]
pub enum AgentResult {
    Success,
    Failure(String),
}

#[async_trait]
pub trait AgentBehavior {
    async fn execute(&self, task_id: &str, state: &StateManager, cost_pressure: &CostPressure, llm: &LlmClient) -> Result<AgentResult>;
}

pub struct Agent {
    agent_type: AgentType,
    llm_client: LlmClient,
}

impl Agent {
    pub fn new(agent_type: AgentType, llm_client: LlmClient) -> Self {
        Self {
            agent_type,
            llm_client,
        }
    }

    pub async fn execute(&self, task_id: &str, state: &StateManager) -> Result<AgentResult> {
        // For now, create a temporary cost pressure instance
        // TODO: Pass this in from supervisor
        let cost_pressure = CostPressure::new(state.state_dir.clone());

        match self.agent_type {
            AgentType::ExecutionVerification => {
                ExecutionVerificationAgent.execute(task_id, state, &cost_pressure, &self.llm_client).await
            }
            AgentType::CodeSlop => {
                CodeSlopAgent.execute(task_id, state, &cost_pressure, &self.llm_client).await
            }
            AgentType::Architecture => {
                ArchitectureAgent.execute(task_id, state, &cost_pressure, &self.llm_client).await
            }
            AgentType::UiSnob => {
                UiSnobAgent.execute(task_id, state, &cost_pressure, &self.llm_client).await
            }
        }
    }
}

// Execution Verification Agent - The Truth Anchor
pub struct ExecutionVerificationAgent;

#[async_trait]
impl AgentBehavior for ExecutionVerificationAgent {
    async fn execute(&self, task_id: &str, state: &StateManager, cost_pressure: &CostPressure, _llm: &LlmClient) -> Result<AgentResult> {
        info!("Execution Verification Agent checking task: {}", task_id);

        let task = state.get_task(task_id)
            .ok_or_else(|| anyhow::anyhow!("Task {} not found", task_id))?;

        let intent = state.get_intent()
            .ok_or_else(|| anyhow::anyhow!("No user intent found"))?;

        // Build prompt for verification
        let prompt = format!(
            "You are the Execution Verification Agent - the truth anchor of the Ralph Wiggum system.

{}

Your task is to verify that the following requirement is actually implemented and working:
\"{}\"

Check if:
1. The application can start successfully
2. The core functionality described works as intended
3. No critical errors occur
4. The implementation matches the user's intent

Respond with either:
- SUCCESS: [brief explanation]
- FAILURE: [detailed explanation of what's wrong]

Be ruthlessly honest. If something doesn't work, say so clearly.",
            cost_pressure.get_cost_context(),
            task.description
        );

        // For now, implement basic verification by trying to run the app
        // TODO: This should be more sophisticated

        let workspace_path = state.state_dir.parent().unwrap().join("workspace");

        // Try to start the application
        let can_start = if workspace_path.join("package.json").exists() {
            // Node.js project
            let output = Command::new("cd")
                .arg(&workspace_path)
                .output();

            match output {
                Ok(result) if result.status.success() => {
                    info!("Workspace directory exists");
                    true
                }
                _ => {
                    warn!("Cannot access workspace directory");
                    false
                }
            }
        } else {
            // No app yet, which is fine for early tasks
            info!("No application exists yet - this is expected for early development");
            true
        };

        if can_start {
            Ok(AgentResult::Success)
        } else {
            Ok(AgentResult::Failure("Application cannot start or workspace is inaccessible".to_string()))
        }
    }
}

// Code Slop Agent - Entropy Control
pub struct CodeSlopAgent;

#[async_trait]
impl AgentBehavior for CodeSlopAgent {
    async fn execute(&self, task_id: &str, state: &StateManager, cost_pressure: &CostPressure, _llm: &LlmClient) -> Result<AgentResult> {
        info!("Code Slop Agent analyzing task: {}", task_id);

        // TODO: Implement linting, complexity analysis, duplication detection
        // For now, just check if workspace exists and has some structure

        let workspace_path = state.state_dir.parent().unwrap().join("workspace");

        if !workspace_path.exists() {
            return Ok(AgentResult::Success); // No code yet, no slop
        }

        // Basic checks - TODO: Make these more sophisticated
        let has_package_json = workspace_path.join("package.json").exists();
        let has_git = workspace_path.join(".git").exists();

        if has_package_json && has_git {
            Ok(AgentResult::Success)
        } else {
            Ok(AgentResult::Failure("Codebase structure incomplete".to_string()))
        }
    }
}

// Architecture Agent - Global Shape Control
pub struct ArchitectureAgent;

#[async_trait]
impl AgentBehavior for ArchitectureAgent {
    async fn execute(&self, task_id: &str, state: &StateManager, cost_pressure: &CostPressure, _llm: &LlmClient) -> Result<AgentResult> {
        info!("Architecture Agent evaluating task: {}", task_id);

        // TODO: Implement architectural analysis
        // For now, just approve
        Ok(AgentResult::Success)
    }
}

// UI Snob Agent - Aesthetics Enforcer
pub struct UiSnobAgent;

#[async_trait]
impl AgentBehavior for UiSnobAgent {
    async fn execute(&self, task_id: &str, state: &StateManager, cost_pressure: &CostPressure, _llm: &LlmClient) -> Result<AgentResult> {
        info!("UI Snob Agent critiquing task: {}", task_id);

        // TODO: Implement UI analysis with screenshots, DOM inspection, etc.
        // For now, just approve
        Ok(AgentResult::Success)
    }
}