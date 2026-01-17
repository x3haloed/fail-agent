use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};
use std::fs;
use anyhow::Result;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CostTracker {
    pub iterations: u64,
    pub llm_tokens: u64,
    pub failures: u64,
    pub start_time: chrono::DateTime<chrono::Utc>,
    pub last_updated: chrono::DateTime<chrono::Utc>,
}

impl Default for CostTracker {
    fn default() -> Self {
        Self {
            iterations: 0,
            llm_tokens: 0,
            failures: 0,
            start_time: chrono::Utc::now(),
            last_updated: chrono::Utc::now(),
        }
    }
}

pub struct CostPressure {
    state_dir: PathBuf,
    tracker: CostTracker,
}

impl CostPressure {
    pub fn new(state_dir: PathBuf) -> Self {
        Self {
            state_dir,
            tracker: CostTracker::default(),
        }
    }

    pub fn load(state_dir: &Path) -> Result<Self> {
        let cost_path = state_dir.join("cost.json");

        let tracker = if cost_path.exists() {
            let content = fs::read_to_string(cost_path)?;
            serde_json::from_str(&content)?
        } else {
            CostTracker::default()
        };

        Ok(Self {
            state_dir: state_dir.to_path_buf(),
            tracker,
        })
    }

    pub fn save(&self) -> Result<()> {
        let cost_path = self.state_dir.join("cost.json");
        let content = serde_json::to_string_pretty(&self.tracker)?;
        fs::write(cost_path, content)?;
        Ok(())
    }

    pub fn increment_iteration(&mut self) {
        self.tracker.iterations += 1;
        self.tracker.last_updated = chrono::Utc::now();
    }

    pub fn add_llm_tokens(&mut self, tokens: u64) {
        self.tracker.llm_tokens += tokens;
        self.tracker.last_updated = chrono::Utc::now();
    }

    pub fn increment_failures(&mut self) {
        self.tracker.failures += 1;
        self.tracker.last_updated = chrono::Utc::now();
    }

    pub fn get_cost_context(&self) -> String {
        format!(
            "Current cost state:\n- Iterations: {}\n- LLM tokens used: {}\n- Failures: {}\n- Runtime: {:.2} hours\n\nIteration is expensive. Fix holistically.",
            self.tracker.iterations,
            self.tracker.llm_tokens,
            self.tracker.failures,
            (chrono::Utc::now() - self.tracker.start_time).num_seconds() as f64 / 3600.0
        )
    }

    pub fn should_escalate(&self) -> bool {
        // Escalate if we have too many failures relative to iterations
        let failure_rate = if self.tracker.iterations > 0 {
            self.tracker.failures as f64 / self.tracker.iterations as f64
        } else {
            0.0
        };

        failure_rate > 0.3 // More than 30% failure rate
    }

    pub fn is_thrashing(&self) -> bool {
        // Detect if we're making no progress (high iterations, high failures)
        self.tracker.iterations > 50 && self.tracker.failures > self.tracker.iterations / 2
    }

    pub fn get_tracker(&self) -> &CostTracker {
        &self.tracker
    }
}