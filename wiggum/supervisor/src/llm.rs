use anyhow::Result;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::time::Duration;

#[derive(Debug, Clone)]
pub struct LlmClient {
    client: Client,
    base_url: String,
}

#[derive(Debug, Serialize)]
struct ChatCompletionRequest {
    model: String,
    messages: Vec<ChatMessage>,
    temperature: f32,
    max_tokens: Option<u32>,
}

#[derive(Debug, Serialize, Deserialize)]
struct ChatMessage {
    role: String,
    content: String,
}

#[derive(Debug, Deserialize)]
struct ChatCompletionResponse {
    choices: Vec<Choice>,
}

#[derive(Debug, Deserialize)]
struct Choice {
    message: ChatMessage,
}

impl LlmClient {
    pub fn new(base_url: &str) -> Result<Self> {
        let client = Client::builder()
            .timeout(Duration::from_secs(300)) // 5 minute timeout for long tasks
            .build()?;

        Ok(Self {
            client,
            base_url: base_url.to_string(),
        })
    }

    pub async fn chat_completion(&self, prompt: &str, model: &str) -> Result<String> {
        let request = ChatCompletionRequest {
            model: model.to_string(),
            messages: vec![ChatMessage {
                role: "user".to_string(),
                content: prompt.to_string(),
            }],
            temperature: 0.1, // Low temperature for deterministic coding tasks
            max_tokens: Some(4096),
        };

        let response = self.client
            .post(&self.base_url)
            .json(&request)
            .send()
            .await?;

        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await.unwrap_or_default();
            return Err(anyhow::anyhow!("LLM request failed: {} - {}", status, body));
        }

        let completion: ChatCompletionResponse = response.json().await?;
        let content = completion.choices
            .into_iter()
            .next()
            .ok_or_else(|| anyhow::anyhow!("No choices in LLM response"))?
            .message
            .content;

        Ok(content)
    }

    pub async fn is_available(&self) -> bool {
        // Simple health check
        self.client
            .get(&format!("{}/models", self.base_url.trim_end_matches("/v1/chat/completions")))
            .send()
            .await
            .map(|r| r.status().is_success())
            .unwrap_or(false)
    }
}