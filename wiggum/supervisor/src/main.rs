use clap::{Parser, Subcommand};
use ralph_wiggum_supervisor::{Supervisor, SupervisorConfig};
use std::path::PathBuf;
use tracing::{info, error};

#[derive(Parser)]
#[command(name = "ralph-wiggum-supervisor")]
#[command(about = "Ralph Wiggum Autonomous Development System Supervisor")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Run one tick of the development loop
    Tick {
        /// Path to the state directory
        #[arg(long, default_value = "../state")]
        state_dir: PathBuf,
    },
    /// Initialize a new development session
    Init {
        /// User intent description
        intent: String,
        /// Path to state directory
        #[arg(long, default_value = "../state")]
        state_dir: PathBuf,
    },
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let cli = Cli::parse();

    match cli.command {
        Commands::Tick { state_dir } => {
            info!("Running supervisor tick");

            let config = SupervisorConfig {
                state_dir,
                lm_studio_url: "http://localhost:1234/v1/chat/completions".to_string(),
            };

            let mut supervisor = Supervisor::new(config).await?;
            supervisor.tick().await?;
        }
        Commands::Init { intent, state_dir } => {
            info!("Initializing new development session");

            let config = SupervisorConfig {
                state_dir: state_dir.clone(),
                lm_studio_url: "http://localhost:1234/v1/chat/completions".to_string(),
            };

            Supervisor::initialize(intent, config).await?;
            info!("Session initialized. Run 'tick' to start development.");
        }
    }

    Ok(())
}