use crate::{
    state::{StateManager, TaskStatus},
    agents::{Agent, AgentType, AgentResult},
    llm::LlmClient,
    cost::CostPressure,
};
use anyhow::{anyhow, Result};
use std::path::PathBuf;
use tracing::{info, warn};

#[derive(Debug, Clone)]
pub struct SupervisorConfig {
    pub state_dir: PathBuf,
    pub lm_studio_url: String,
}

pub struct Supervisor {
    config: SupervisorConfig,
    state: StateManager,
    llm_client: LlmClient,
    cost_pressure: CostPressure,
}

impl Supervisor {
    pub async fn new(config: SupervisorConfig) -> Result<Self> {
        let state = StateManager::load(&config.state_dir)?;
        let llm_client = LlmClient::new(&config.lm_studio_url)?;
        let cost_pressure = CostPressure::load(&config.state_dir)?;

        Ok(Self {
            config,
            state,
            llm_client,
            cost_pressure,
        })
    }

    pub async fn initialize(intent: String, config: SupervisorConfig) -> Result<()> {
        // Create state directory if it doesn't exist
        std::fs::create_dir_all(&config.state_dir)?;

        // Initialize state with user intent
        let mut state_manager = StateManager::new(config.state_dir.clone());
        state_manager.set_intent(intent)?;
        state_manager.save()?;

        // Initialize cost tracker
        let cost_pressure = CostPressure::new(config.state_dir.clone());
        cost_pressure.save()?;

        info!("Ralph Wiggum system initialized with user intent");
        Ok(())
    }

    pub async fn tick(&mut self) -> Result<()> {
        info!("Starting supervisor tick");

        // Increment cost counter
        self.cost_pressure.increment_iteration();

        // Check if we should exit the loop
        if self.should_exit()? {
            info!("All verification gates passed. Requesting loop exit.");
            std::process::exit(42);
        }

        // Get next task to work on
        let next_task = self.decide_next_task()?;

        match next_task {
            Some(task_id) => {
                info!("Working on task: {}", task_id);
                self.execute_task(task_id).await?;
            }
            None => {
                // No tasks pending - this shouldn't happen if should_exit() is working correctly
                warn!("No pending tasks but exit conditions not met. This indicates a logic error.");
            }
        }

        // Save state
        self.state.save()?;
        self.cost_pressure.save()?;

        Ok(())
    }

    fn should_exit(&self) -> Result<bool> {
        // If no intent is set, we haven't started yet
        if self.state.get_intent().is_none() {
            return Ok(false);
        }

        // If no tasks exist at all, we need to create them first
        if !self.state.has_tasks() {
            return Ok(false);
        }

        // Check if all tasks are completed
        if !self.state.all_tasks_completed()? {
            return Ok(false);
        }

        // Run all verification gates
        if !self.run_verification_gates()? {
            return Ok(false);
        }

        info!("All exit conditions met");
        Ok(true)
    }

    fn decide_next_task(&mut self) -> Result<Option<String>> {
        // If no tasks exist yet, create initial tasks from user intent
        let pending_tasks = self.state.get_pending_tasks()?;
        if pending_tasks.is_empty() && self.state.get_intent().is_some() {
            self.create_initial_tasks()?;
            // Reload pending tasks after creation
            let pending_tasks = self.state.get_pending_tasks()?;
            if pending_tasks.is_empty() {
                // If still no tasks, something went wrong
                return Ok(None);
            }
        }

        // Simple priority-based task selection
        // In a real implementation, this would be more sophisticated
        let tasks = self.state.get_pending_tasks()?;

        if tasks.is_empty() {
            return Ok(None);
        }

        // For now, just return the first pending task
        Ok(Some(tasks[0].id.clone()))
    }

    fn create_initial_tasks(&mut self) -> Result<()> {
        // TODO: Use LLM to decompose user intent into tasks
        // For now, create a simple placeholder task
        self.state.add_task("Implement basic application structure".to_string())?;
        info!("Created initial tasks from user intent");
        Ok(())
    }

    async fn execute_task(&mut self, task_id: String) -> Result<()> {
        info!("Executing task: {}", task_id);

        // Mark task as in progress
        self.state.update_task_status(&task_id, TaskStatus::InProgress)?;

        // Create and dispatch the appropriate agent
        // For now, we'll start with the Execution Verification Agent
        // TODO: Implement proper agent selection logic

        let agent = Agent::new(AgentType::ExecutionVerification, self.llm_client.clone());
        let result = agent.execute(&task_id, &self.state).await?;

        match result {
            AgentResult::Success => {
                info!("Task {} completed successfully", task_id);
                self.state.update_task_status(&task_id, TaskStatus::Completed)?;
            }
            AgentResult::Failure(reason) => {
                warn!("Task {} failed: {}", task_id, reason);
                self.state.update_task_status(&task_id, TaskStatus::Pending)?;
                // TODO: Feed failure back into the loop for retry
            }
        }

        Ok(())
    }

    fn run_verification_gates(&self) -> Result<bool> {
        // TODO: Implement all verification gates:
        // - Execution Verification Agent
        // - Code Slop Agent
        // - Architecture Agent
        // - UI Agent

        // For now, just check if all tasks are completed
        // This is a placeholder implementation
        Ok(self.state.all_tasks_completed()?)
    }
}