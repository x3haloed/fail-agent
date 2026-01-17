use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};
use std::fs;
use chrono::{DateTime, Utc};
use anyhow::Result;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Intent {
    pub description: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TaskStatus {
    Pending,
    InProgress,
    Completed,
    Failed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Task {
    pub id: String,
    pub description: String,
    pub status: TaskStatus,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskList {
    pub tasks: Vec<Task>,
}

pub struct StateManager {
    pub state_dir: PathBuf,
    intent: Option<Intent>,
    tasks: TaskList,
}

impl StateManager {
    pub fn new(state_dir: PathBuf) -> Self {
        Self {
            state_dir,
            intent: None,
            tasks: TaskList { tasks: Vec::new() },
        }
    }

    pub fn load(state_dir: &Path) -> Result<Self> {
        let intent_path = state_dir.join("intent.json");
        let tasks_path = state_dir.join("tasks.json");

        let intent = if intent_path.exists() {
            let content = fs::read_to_string(intent_path)?;
            Some(serde_json::from_str(&content)?)
        } else {
            None
        };

        let tasks = if tasks_path.exists() {
            let content = fs::read_to_string(tasks_path)?;
            serde_json::from_str(&content)?
        } else {
            TaskList { tasks: Vec::new() }
        };

        Ok(Self {
            state_dir: state_dir.to_path_buf(),
            intent,
            tasks,
        })
    }

    pub fn save(&self) -> Result<()> {
        fs::create_dir_all(&self.state_dir)?;

        if let Some(intent) = &self.intent {
            let intent_path = self.state_dir.join("intent.json");
            let content = serde_json::to_string_pretty(intent)?;
            fs::write(intent_path, content)?;
        }

        let tasks_path = self.state_dir.join("tasks.json");
        let content = serde_json::to_string_pretty(&self.tasks)?;
        fs::write(tasks_path, content)?;

        Ok(())
    }

    pub fn set_intent(&mut self, description: String) -> Result<()> {
        self.intent = Some(Intent {
            description,
            created_at: Utc::now(),
        });
        Ok(())
    }

    pub fn get_intent(&self) -> Option<&Intent> {
        self.intent.as_ref()
    }

    pub fn add_task(&mut self, description: String) -> Result<String> {
        let id = format!("task_{}", self.tasks.tasks.len() + 1);
        let task = Task {
            id: id.clone(),
            description,
            status: TaskStatus::Pending,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };

        self.tasks.tasks.push(task);
        Ok(id)
    }

    pub fn update_task_status(&mut self, task_id: &str, status: TaskStatus) -> Result<()> {
        if let Some(task) = self.tasks.tasks.iter_mut().find(|t| t.id == task_id) {
            task.status = status;
            task.updated_at = Utc::now();
            Ok(())
        } else {
            Err(anyhow::anyhow!("Task {} not found", task_id))
        }
    }

    pub fn get_pending_tasks(&self) -> Result<Vec<&Task>> {
        Ok(self.tasks.tasks.iter()
            .filter(|t| matches!(t.status, TaskStatus::Pending))
            .collect())
    }

    pub fn all_tasks_completed(&self) -> Result<bool> {
        Ok(self.tasks.tasks.iter()
            .all(|t| matches!(t.status, TaskStatus::Completed)))
    }

    pub fn get_task(&self, task_id: &str) -> Option<&Task> {
        self.tasks.tasks.iter().find(|t| t.id == task_id)
    }

    pub fn has_tasks(&self) -> bool {
        !self.tasks.tasks.is_empty()
    }
}