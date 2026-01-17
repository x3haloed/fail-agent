I want you to put together a plan do "Ralph Wiggum" development with agents that actually works.

Here is the broad outline:
- Geoffrey Huntley "bash loop" at the trunk
- One primary agent that controls all the rest
- Agents that:
  - Verify execution correctness against original user intent. (must be able to run the program and use it like a human)
  - Oversee codebase slop (DRY failures, spaghetti nonsese), which leads to:
  - Tackle scoped architecture problems (how to turn 10k lines of junk into an elegant system)
  - UI design snob. ("this is off by two pixels, fix it")
- The primary agent must be extremely good about ensuring *everything always works 100% as the user intended* before asking to be let out of the loop.

Plan for Implementing a “Ralph Wiggum” Autonomous Development System

Introduction

This plan outlines a multi-agent autonomous development workflow – often nicknamed the “Ralph Wiggum” loop – that can build full-stack web applications from a natural language specification. The goal is a fully autonomous system: the user provides a project description in plain English (with the primary agent asking a few clarifying questions if needed), and the agents take it from there, delivering a complete, working web app with no partial results. We target full-stack web apps (covering both frontend UI and backend logic) as the main use-case, since this exercises a broad range of development tasks. The entire system is intended to run locally (on the user’s machine – macOS or otherwise), with appropriate sandboxing for safety, and it will not “exit” or stop until the application meets 100% of the specified requirements and quality standards.

Orchestrator Agent and the Infinite Loop Mechanism

At the heart of the system is a primary orchestrator agent (the “trunk”). This lead agent is responsible for managing the development process and coordinating all other specialist agents. In essence, the orchestrator implements a Ralph Wiggum-style loop, continually driving progress until the project is complete. As Geoffrey Huntley (creator of the Ralph loop concept) put it, “Ralph is a Bash loop.” ￼ In other words, the simplest form of this technique is an infinite loop script that repeatedly invokes an AI coding agent with the latest task or context until a completion condition is reached ￼. Progress persists between iterations not in the model’s short-term memory, but in the codebase itself (files, git history, etc.), so each loop iteration starts fresh with respect to AI context but a bit further along in the code ￼ ￼. This naive but persistent approach – “deterministically bad in an indeterministic world” as Huntley quips – ensures the agent will brute-force its way through problems via iteration, rather than giving up or timing out early ￼.

The orchestrator’s loop works roughly as follows: it picks the next development task, sends it to a coding agent to implement, then verifies the result. If the task isn’t fully satisfied, the orchestrator feeds feedback or corrections back into the agent and repeats the cycle. This “fail until you succeed” strategy leverages automated checks to know when the code is truly done. A completion token or flag is used to detect success – for example, Anthropic’s official Ralph plugin looks for a special <promise>COMPLETE</promise> output when the agent believes all acceptance criteria are met ￼. The orchestrator will intercept any attempt by the agent to finish if the objectives aren’t actually achieved, effectively refusing to let the AI quit prematurely ￼. Instead, it forces another iteration with the latest feedback. By doing so, the system avoids partial or half-working deliverables – the loop runs until all tests pass and requirements are satisfied ￼. This forms the backbone of our development pipeline.

Multi-Agent Architecture and Roles

Instead of a single monolithic agent, we employ a multi-agent architecture with an orchestrator-worker pattern. The primary orchestrator (lead agent) coordinates multiple specialized sub-agents, each with a focused role in the development process ￼. This separation of concerns improves reliability and mirrors how real software teams have different experts (QA, code reviewers, etc.). The lead agent’s job is to delegate tasks to these specialists and integrate their feedback.

Example of a multi-agent architecture with a lead orchestrator agent coordinating specialized subagents (from Anthropic’s research system) ￼. Our development system follows a similar orchestrator-worker pattern, where the primary agent spawns and manages agents for coding, testing, code review, etc.

Breaking out the responsibilities into different agents allows parallelism where appropriate and more targeted prompt specialization. Below are the key agent roles in our system and how they work together:

1. Execution Verification Agent (Testing & QA)

This agent acts as a relentless QA tester that ensures the software actually works as intended. After the coding agent (described later as part of the orchestrator loop) produces or updates the application code, the verification agent automatically runs the application and its test suite to verify execution correctness. It must use the program “like a human” would – clicking through the UI, calling APIs, or running automated test scripts – to confirm that the original user requirements are met in practice. In implementation, this can involve running unit tests, integration tests, and end-to-end tests that correspond to the acceptance criteria of each feature. For example, in the Ralph Wiggum methodology each user story in the Product Requirements Document (PRD) carries its own verifiable acceptance tests or quality gates ￼. The verification agent executes these tests (e.g. via a command like bun run test or a similar test runner) and checks that all tests pass for the feature ￼. If any test fails or if any aspect of the app behaves unexpectedly, this agent reports the discrepancies to the orchestrator.

The orchestrator will treat a failing test as a signal that the code is not correct or complete. It then prompts the coding agent to fix the issue in the next loop iteration, supplying the error output or a description of how the app’s behavior deviates from the user’s intent. This tight feedback loop (code -> test -> fix) continues until the feature’s tests all pass, guaranteeing that execution is correct by objective measures. As one expert noted, using strong feedback loops like type-checking and unit tests is crucial: if the code compiles and all tests pass, the AI emits the completion token; if not, the loop forces it to try again ￼. In practice, the verification agent can employ tools like Playwright or Selenium to simulate a user clicking through the web UI for end-to-end tests. In fact, community members have found that combining Ralph-style loops with Playwright UI testing is extremely powerful – in one case, an autonomous agent using Xcode’s build tools and Playwright was able to perform extensive UI work overnight, anecdotally “minting millionaires” due to the productivity gain ￼. This illustrates the importance of having a rigorous, automated user-level verification step: the system should catch any functional or UX flaws and not proceed until they are fixed.

2. Code Quality & Refactoring Agent

Even if the feature works, the job isn’t done – we want high-quality, maintainable code. The Code Quality agent’s role is to review the codebase for “code slop” – things like duplicated code (DRY principle violations), overly complex or spaghetti code, poor naming, missing documentation, and any deviations from best practices. Essentially, this agent performs an automated code review after the coding agent’s changes. It might run static analysis tools (linters, code formatters, complexity analyzers) and also use its own LLM reasoning to spot smells in the code. For instance, it can detect if the same logic appears in multiple places and should be refactored into a function, or if a function is doing too many things and needs to be split. If the project is in TypeScript/JavaScript, the agent ensures lint checks and type checks pass (bun run lint and bun run typecheck as in the Ralph example) ￼, and that the code conforms to style guides.

When issues are found, the Code Quality agent doesn’t directly modify code but rather feeds recommendations back to the orchestrator (or possibly directly to the coding agent). The orchestrator will create tasks for the coding agent to refactor the code accordingly. For example, if the quality agent flags that a certain module has high duplication, the orchestrator might prompt the coding agent: “Refactor Module X to eliminate duplicate logic per the code review feedback.” This leads to a new iteration in the loop focused on improving internal quality without changing functionality. The inclusion of this agent ensures the codebase isn’t just functioning, but also clean and maintainable. Over successive iterations, this can gradually turn a rough initial implementation into well-structured code. (Notably, in the Ralph Wiggum loop philosophy, quality gates can be enforced as part of each task – e.g. requiring lint and type-check to pass for every story, not just at the end ￼ – so our system embraces that by making the code quality agent an integral participant from early on.)

3. Architecture Optimization Agent

While the code quality agent handles micro-level cleanliness, the Architecture agent looks at the big picture structure of the application. As the project grows (imagine the system has churned out 10,000 lines of code across many files), this agent evaluates higher-level design and can propose major refactoring or re-architecting to maintain an elegant system design. It’s essentially an AI software architect overseeing the project’s modular structure, adherence to chosen architectural patterns, and overall scalability. The architecture agent might analyze how responsibilities are divided among services or components, check for proper layering (UI vs business logic vs data access separation), and see if any part of the codebase has become a “God object” or monolith that should be broken down. It may also consider performance implications of the current design (e.g. if the web app is full-stack, are the client-server interactions efficient? do we need caching or a different data model?).

If architectural issues are detected – say, the agent finds that the code is “junk-drawer” style spaghetti – it will form a plan to refactor at a system level. This could include creating new modules, reorganizing file/project structure, or introducing design patterns to replace ad-hoc implementations. The orchestrator can then task the coding agent with a series of refactoring steps guided by this plan. For example, the architecture agent might suggest: “The authentication logic is duplicated in backend and frontend – unify it by creating a shared auth service module,” or “Split the single 1000-line data processing script into a pipeline of smaller functions or classes.” These suggestions are fed into the loop as new to-dos. The important thing is that scoped architecture improvements are tackled incrementally within the autonomous loop – the system doesn’t consider the project truly done if the design is overly brittle or beyond what a human team would consider acceptable for maintenance. By continuously pruning and reorganizing the codebase, the architecture agent ensures the final deliverable isn’t just a quick hack, but a robust solution that could be extended in future iterations. (It’s worth noting that truly deep architectural decisions still benefit from human judgment ￼, but for our purposes the agent can handle obvious structural problems. The Ralph Wiggum pattern is best at mechanical, deterministic refactoring tasks – e.g. upgrading dependencies, applying known patterns – rather than making creative architectural leaps ￼. So the architecture agent will focus on systematic improvements aligned with known best practices, ensuring the project stays on a solid foundation.)

4. UI/UX Design “Snob” Agent

The UI/UX agent is a specialist focusing on the look and feel of the web application. Its mandate is to scrutinize the user interface and catch any visual or usability issues – essentially being a pixel-perfect designer that won’t tolerate a button being “off by two pixels.” After the core functionality is in place and the basic UI is built by the coding agent, the UI/UX agent wakes up to fine-tune the front-end. This involves rendering the web application (likely in a headless browser environment) and evaluating it against design expectations. If a style guide or design mock is provided, the agent can compare the live UI to those specifications. Even without explicit mocks, the UI agent applies general design principles: checking for consistency in spacing, alignment of elements, proper use of color and typography, responsiveness on different screen sizes, and overall aesthetic polish.

To do this programmatically, the UI agent can leverage tools like visual regression testing and layout analysis. For instance, it might take screenshots of key pages and ensure elements line up to a grid, or use the DOM/CSS Object Model to measure margins and padding around components. Minor misalignments (like an icon that isn’t perfectly centered in a button) will be flagged. The agent also looks at usability: Are interactive elements like links and buttons clearly visible and appropriately sized? Is the app accessible (contrast ratios, ARIA labels, etc.)? If something is suboptimal, the UI/UX agent formulates a fix – e.g., “The submit button on the signup form is 5px too low; adjust its CSS margin,” or “On mobile view, the sidebar overlaps content – improve the responsive layout.” These suggestions go to the orchestrator, which will have the coding agent implement the UI refinements.

In addition, the UI agent can run user simulation tests similar to the verification agent’s, but specifically aimed at UI flows. It might automate a sequence: open page, fill form, click button, and verify the expected page transitions or component updates occur. This overlaps with functional testing, but from a user’s vantage point. By doing this, it can catch issues like “pressing X doesn’t close the modal” or “the loading spinner never disappears,” which are both functional and UX problems. All such findings result in further development iterations to fix them. The end result is a user interface that is not only functionally correct, but also polished to a high standard of design and usability – something a “UI design snob” would approve of. This agent ensures the autonomous system’s output isn’t just code that technically works, but an app that delivers a good user experience out of the box.

Orchestration Workflow and Coordination

With these specialized agents in place, the primary orchestrator agent manages a coordinated workflow to build the application. Here’s how the pieces come together in a typical scenario:
	1.	Clarification and Planning: The user provides a natural language specification of the desired application (for example, “a TODO list app with user login and dark mode”). The orchestrator may ask clarifying questions if anything is ambiguous, much like a good project manager. Once clarity is achieved, the orchestrator decomposes the request into a structured plan – essentially a list of tasks or user stories. (This could be formalized in a PRD file with numbered user stories and acceptance criteria ￼, or maintained internally as a task list.) Each task has defined “done” criteria, including functional requirements and any quality gates (tests that must pass, etc.).
	2.	Task Execution (Coding Agent Loop): The orchestrator picks the highest-priority pending task and spawns a coding agent (such as an instance of an LLM like Claude or GPT specialized for code) to implement it ￼ ￼. It constructs a prompt for the agent that includes the task description, relevant context (existing codebase, previous notes, acceptance criteria, etc.), and instructs the agent to produce the necessary code changes. The coding agent runs in a fresh context for each iteration, relying on the persisted code and notes from prior iterations rather than long conversations ￼. It writes new code or modifies existing code to fulfill the task. Once the coding agent outputs its proposed changes (which might be applied to the project repository programmatically), the orchestrator moves to verification.
	3.	Verification and Feedback: The orchestrator invokes the Execution Verification agent to run all relevant tests and/or launch the app to simulate user behavior for that task. For example, if the task was “Allow users to reset their password,” the verification agent runs the test suite related to password resets and may simulate a user flow of requesting a reset. If all tests pass and the behavior meets the acceptance criteria, the task is considered functionally complete ￼. If any check fails – say the test “email sent to user” did not pass – the orchestrator records the failure. In that case, the orchestrator will loop back: it prompts the coding agent again, providing the failure details as feedback (e.g., error logs, failed assertions, or a description of what went wrong). The coding agent then attempts to fix the issue in code, and the cycle repeats (code -> test -> code…) until the verification agent reports success. This might take several iterations, but thanks to the loop, the agent won’t give up until it gets it right ￼.
	4.	Quality Review and Refactoring: Once the task’s basic functionality is confirmed, the orchestrator engages the Code Quality agent to review the new code (and potentially the entire codebase as it evolves). If the quality agent flags problems – e.g. “This function has duplicate logic” or “Code style not matching conventions” – the orchestrator adds a sub-task for cleanup. The coding agent is then prompted to refactor or fix the code according to these recommendations. After those changes, the verification agent may run tests again to ensure nothing broke. This step may iterate a few times (review -> refactor -> test) until the code quality agent is satisfied (no major warnings, all linters green, etc.). In parallel, if the addition of this feature causes any broader architectural concern (perhaps the codebase is growing messy), the Architecture agent is consulted. It might decide that now or in a later dedicated pass, a larger refactor is needed (for instance, after several features, it could plan to reorganize the project structure). The orchestrator can schedule such architecture-oriented tasks (possibly between major feature tasks or at the end of the development cycle). Each architectural change still goes through testing and quality review as above.
	5.	UI/UX Polish: After the backend logic and core frontend functionality for the task are in place and verified, the orchestrator triggers the UI/UX agent to assess the front-end result of this task. The UI agent checks that the new feature’s interface looks right and follows design best practices. If it finds visual issues or UX flaws, it formulates adjustments. The orchestrator then calls on the coding agent (which in this context will be making front-end code/CSS changes) to implement those UI fixes. This may loop until the UI agent gives a thumbs-up (e.g., the layout is now pixel-perfect and passes all its heuristics). This step ensures each user-facing aspect of the task is refined before moving on.
	6.	Repeat for All Tasks: The orchestrator then marks the current task as completed and moves to the next item in the backlog. It repeats steps 2–5 for each user story or requirement, one by one or possibly in parallel where feasible. The process is deterministic and relentless: tasks are only marked done when all their acceptance tests and quality checks are green ￼. Thanks to the persistent loop approach, completed tasks stay completed (their state is saved in the codebase and a tracker file), and the agent picks up the next unfinished task in priority order ￼. This continues until no tasks remain open.
	7.	Final Integration and System Test: Once all specified features are implemented and individually verified, the system performs a final end-to-end integration test – essentially a full regression run to be absolutely sure everything works together. In truth, by enforcing quality on each story atomically, we minimize integration surprises (each piece was built and tested in isolation with stubs or earlier components). But a final pass with the verification agent running the entire test suite and perhaps additional scenario tests is prudent. If any issue surfaces, the orchestrator will treat it like a new bug to fix (engaging the coding agent, etc.). In the ideal case, this final test passes cleanly because every story was “done” in the strict sense (including all its quality gates) ￼.
	8.	Completion and Exit: Only after everything has been verified to 100% satisfaction does the primary agent consider the project complete. At this point, the orchestrator can output the final codebase to the user and possibly a summary of what was done. It will then gracefully shut down the loop. The key design principle is that the primary agent should “ask to be let out of the loop” only when it has absolute confidence that the user’s intent has been realized in full. In practice, that confidence comes from the battery of automated checks – the passing test suite, linting, type checks, and the approval of the code quality and UI agents. If any objective is unmet, the system is not allowed to stop. (Anthropic’s official implementation formalizes this with a “Stop Hook” that intercepts the agent’s attempt to finish if the completion criteria aren’t satisfied ￼.) By structuring the loop this way, we avoid the common failure of autonomous agents producing half-baked results. The development agents don’t get to declare victory until the app truly works.

Throughout this workflow, the orchestrator is the decision-maker that ensures all these agents operate in concert. It keeps track of state: which tasks are done, which are in progress, and what issues have been found. A simple JSON or markdown tracker (like prd.json or a progress log) is maintained to record each iteration’s outcome and any notes. This persistent memory (along with the evolving codebase) means the system has context even though each agent invocation is stateless. For example, the orchestrator can maintain an AGENTS.md knowledge file where lessons learned (like “the project uses framework X for routing” or “after modifying Y, remember to update Z”) are logged for future iterations ￼. These notes can be injected into prompts so that the agent doesn’t make the same mistake twice. All of these implementation details help in scaling the autonomous loop to larger projects without losing coherence.

Autonomy, Safety, and Performance Considerations

Building a fully autonomous dev loop raises important questions about safety (preventing runaway behavior or damage) and efficiency (controlling costs and time). We address these considerations in the plan as well:
	•	Clear Definition of “Done” to Avoid Infinite Loops: Autonomy means the system could theoretically loop forever if it’s chasing an impossible goal or if “done” is not well-specified. To prevent a scenario where the agent gets stuck in what has been called a “sycophancy loop” (endlessly trying to satisfy an unclear or unachievable promise) ￼, we emphasize having concrete acceptance criteria and tests for every requirement. The user’s intent is translated into verifiable checks (e.g. “user can sign up with email” becomes “simulate signing up, verify a new user record is created and confirmation email sent”). The agent only loops on a task if a specific check is failing, and once it passes, that task is objectively done. By structuring the requirements as a series of binary outcomes (pass/fail checks), we give the agent a clear goalpost for completion. This dramatically reduces the chance of the agent falling into an endless subjective improvement loop, because “good enough” is defined by tests and lint rules rather than the agent’s open-ended judgment. We also implement an escape hatch in the orchestrator: a maximum iteration count for any single task (or for the whole project). For example, we might set --max-iterations 50 for a task; if the agent somehow hasn’t succeeded by then, the loop will break and alert the user ￼. This is a safety net to prevent burning infinite compute on one stubborn bug. In practice, if tasks are well-sized (small in scope) the loop should converge long before hitting such limits ￼.
	•	Cost Awareness and Efficiency (“Yet-Another-Theory-of-Agency”): Each iteration of the loop potentially consumes API calls to an LLM and CPU time for running tests, etc. While the system could just bruteforce endlessly, it’s desirable to encourage efficient problem-solving. One intriguing strategy (inspired by the “yet-another-theory-of-agency” the user alluded to) is to impose a form of cost pressure on the agents. In other words, make the agents act as if each iteration or token has a cost (which in reality it does, in terms of time or money), so they have an incentive to solve tasks in fewer tries. Research indicates that removing cost constraints can actually lead to stagnation in agent behavior. For example, in a long-horizon simulation benchmark, when agents were not penalized by costs, they tended to get stuck or underperform; conversely, having a budget or fee to consider pushed the agents to be more decisive and effective ￼. We can leverage this insight by configuring our orchestrator and agents with a notional “budget”. Concretely, the orchestrator might say to the coding agent (in the prompt): “You have at most N attempts to get this working” or “Each iteration is expensive, so try to fix everything in one go if possible.” This encourages the agent to plan more carefully and check its work, rather than relying on endless trial-and-error. It’s a subtle psychological steering, but it can improve performance by simulating real-world constraints (much like a human developer works more deliberately under a deadline or budget limit). Of course, the system will still use multiple iterations if needed – we don’t stop at N if the job isn’t done – but this cost-aware prompting can reduce unnecessary loops. On the flip side, we must monitor actual costs: an autonomous loop can rack up API usage. As a safeguard, we track tokens and time, and if a task seems to be thrashing without progress, the orchestrator might pause and either escalate the issue (try a different strategy or model) or ultimately ask for human intervention if all else fails (though that’s a last resort, considered a failure of autonomy). The Anthropic team notes that multi-agent systems inherently use more tokens (15× more than single-agent chats in one analysis) and thus should be applied to high-value tasks where the outcome merits the cost ￼. In our case, building a full app autonomously is indeed a high-value outcome, but we still aim to keep the process efficient via the above measures.
	•	Safety and Sandbox Execution: Running an autonomous coding agent locally means it will be executing code on the user’s machine – this is powerful but potentially dangerous. We take safety seriously by sandboxing the development environment. The code is built and tested either inside a restricted environment (like a Docker container or a VM) or with careful permission controls. This prevents the AI from accidentally harming the host system. Notably, the Ralph Wiggum approach often requires giving the agent broad access to tools (for example, the official plugin has a --dangerously-skip-permissions mode to let the agent run shell commands to install dependencies, run servers, etc.) ￼. To mitigate risks, the plan is to confine these operations to a safe sandbox. For instance, we can spin up a local Docker container that has all the development tools and a copy of the code, and let the agent operate freely within it (install packages, start the dev server, run database migrations, etc.). If the agent makes a mistake like deleting a wrong file or introducing a security vulnerability, the host system remains unaffected and we can roll back the container state if needed. Using a Mac, the user can take advantage of containerization or at least a separate user account with limited permissions for the agent process. Furthermore, we log every command the agent executes, and the orchestrator can be programmed to catch obviously dangerous actions (e.g., if the agent tries to modify system directories, the orchestrator will block that and redirect the agent back to the task at hand). By following best practices (as recommended by experts ￼), we ensure that autonomy doesn’t come at the expense of security. The system is fully autonomous in operation, but always under a controlled environment.
	•	Contemporary Frameworks and Tooling: Finally, to “future-proof” our autonomous dev pipeline, we choose frameworks and libraries that are modern and actively maintained, rather than outdated technology. This is important because the agents will work more effectively with well-documented, widely used stacks (more prior knowledge to draw on, more community examples) and the end product will be more relevant. For our full-stack web app use-case, a great example of a fresh framework is RedwoodJS. RedwoodJS is a relatively new (but rapidly growing) full-stack JavaScript/TypeScript framework that integrates React (frontend), GraphQL, and a Node/Prisma backend in a unified way ￼. It’s designed to be developer-friendly and comes with built-in testing and deployment setups, which align well with our automated approach. Because Redwood is actively maintained and has a growing community, it avoids the pitfalls of using a “stale” framework that might lack support. Another modern choice could be SvelteKit (if leaning more on the front-end side with a lightweight backend) or Next.js with the latest App Router features – both are widely adopted and continuously improved. The key is that whichever stack we use, it should be one where momentum is forward-looking (no legacy baggage). This ensures that the code our agents produce is up-to-date with current standards and that the system can fetch solutions to problems from current documentation. We will also utilize cutting-edge tools like Bun (an extremely fast JavaScript runtime) for tasks like running tests and typechecks, as was demonstrated in Ralph TUI’s quality gates ￼. These tools not only speed up the loop (faster test runs mean faster iterations) but also signal that our framework is modern (for instance, Bun support indicates a forward-thinking project). By sticking to a fresh tech stack, we make it easier for the autonomous agents to meet quality standards – the frameworks themselves enforce structure and the community best practices are encoded in the linters/CLI tools that come with them. Plus, if the user later extends or maintains the generated app, they’ll be working with a current technology stack that has a future, rather than an obsolete one.

In summary, this plan brings together the relentless iteration of the Ralph Wiggum loop with a team of specialized AI agents to ensure every facet of development is covered. The primary orchestrator keeps everyone (or rather, every agent) in line, looping until all criteria are met and not letting the AI call it “done” until it’s really done ￼. By verifying functionality with tests, reviewing code quality, optimizing architecture, and polishing the UI – all autonomously – the system can deliver a fully functional, clean and user-friendly web application straight from a natural language spec. And it achieves this while leveraging the latest frameworks and safeguarding the process (both in terms of not going overboard on cost or risk). This is “Ralph Wiggum” development done right: an orchestrated, persistent push to the finish line, where every failure is just data for the next attempt ￼, and the end result is working software that meets the user’s intent in its entirety.

Sources
	•	Huntley, G. Inventing the Ralph Wiggum Loop. Dev Interrupted Podcast (2026) – “Ralph is a Bash loop.” ￼
	•	The Good Programmer (2026). The Ralph Wiggum Pattern: Automation and Persistence for Coding Agents. – Explanation of the Ralph loop phases and quality gates ￼ ￼.
	•	VentureBeat (Jan 2026). How Ralph Wiggum went from ‘The Simpsons’ to the biggest name in AI. – Describes the stop-hook mechanism and success with tests ￼ ￼, plus notes on cost considerations ￼ and sandbox safety ￼.
	•	Anthropic Engineering (Oct 2025). How we built our multi-agent research system. – Insights into orchestrator-worker agent architecture ￼ and token usage in multi-agent systems ￼.
	•	Big News Network (2025). Top 7 Frontend Frameworks to Use in 2025. – Notes RedwoodJS as a fresh full-stack framework for modern apps ￼.
	•	Backlund, A. & Petersson, L. (2025). Vending-Bench: Long-Term Coherence of Autonomous Agents. – Suggests cost constraints improve agent performance (removing cost pressure led to stagnation) ￼.
	•	Community examples (X/Twitter posts) – e.g. using Playwright UI tests with Ralph loops ￼ demonstrating the power of autonomous UI verification.

OK, I'm having a hard time comprehending this. Can you please make a condensed version that's a little closer to an architectural design doc?

Got it. Let’s collapse this into something that reads like a real architectural design doc, not an essay.
This is intentionally terse, structural, and operational.

⸻

Ralph Wiggum Autonomous Development System

Architectural Design Document (Condensed)

1. Goal

Build a fully autonomous, local, agent-based system that takes a natural-language spec for a full-stack web app and delivers a complete, correct, polished application.

Hard constraint:
Nothing is ever considered “done” unless it works exactly as the user intended.

If autonomy fails → system design failed.

⸻

2. Core Principle: The Trunk Loop (Ralph Loop)

Everything runs inside a persistent bash-style loop.

while !EXIT_APPROVED:
    PrimaryAgent.decide_next_step()
    PrimaryAgent.dispatch_agents()
    PrimaryAgent.verify_objectives()

Key properties:
	•	Stateless agents, stateful world
	•	State lives in files, repo, test results, logs
	•	Agents are disposable
	•	The loop never stops on “confidence”
	•	It only stops on objective verification

The loop is the system. Everything else is just behavior inside it.

⸻

3. System Topology

┌───────────────────────────┐
│       TRUNK LOOP          │  (bash / supervisor)
│                           │
│  ┌─────────────────────┐ │
│  │   PRIMARY AGENT     │◄┼────── user intent
│  └─────────────────────┘ │
│       │   │   │   │      │
│       ▼   ▼   ▼   ▼      │
│  Verify  Slop  Arch  UI  │
│  Agent   Agent Agent Agent
└───────────────────────────┘

	•	One Primary Agent
	•	Multiple specialist agents
	•	Specialists never coordinate with each other
	•	Only the Primary Agent has authority

⸻

4. Primary Agent (Orchestrator)

Responsibilities
	•	Owns user intent
	•	Owns task decomposition
	•	Owns loop exit permission
	•	Applies cost pressure
	•	Decides when and why to call sub-agents

Rules
	•	May ask clarifying questions only at the beginning
	•	After commitment, must make judgment calls like a senior PM
	•	Never delivers “partial”
	•	Never exits the loop unless all verification gates pass

Outputs
	•	Task plan
	•	Agent dispatch instructions
	•	Loop continuation / exit decision

⸻

5. Specialist Agents (Strictly Scoped)

5.1 Execution Verification Agent (Truth Anchor)

Purpose:
Answer: “Does this actually do what the user asked?”

Capabilities
	•	Run the app
	•	Click the UI (Playwright-style)
	•	Call APIs
	•	Run test suites
	•	Compare behavior against original intent

Authority
	•	Can veto completion
	•	Primary Agent must obey failures

This agent defines reality.

⸻

5.2 Code Slop Agent (Local Hygiene)

Purpose:
Prevent entropy.

Detects
	•	DRY violations
	•	Spaghetti control flow
	•	Dead code
	•	Overgrown files
	•	Naming incoherence

Outputs
	•	Refactor instructions only
	•	Never changes behavior

⸻

5.3 Architecture Agent (Global Shape)

Purpose:
Keep the system elegant at scale.

Triggers
	•	Codebase exceeds complexity thresholds
	•	Multiple slop signals across modules
	•	Repeated structural patterns emerging

Actions
	•	Proposes scoped refactors
	•	Re-partitions systems
	•	Introduces boundaries

This agent turns 10k lines of junk into something survivable.

⸻

5.4 UI Design Snob Agent (Aesthetic Enforcer)

Purpose:
Make the UI not embarrassing.

Checks
	•	Pixel alignment
	•	Spacing consistency
	•	Responsiveness
	•	Interaction affordances
	•	Visual regressions

Tools
	•	Screenshots
	•	DOM inspection
	•	Layout metrics

Authority
	•	Can block completion on “almost right”

⸻

6. Verification Gates (Non-Negotiable)

A task is complete only if all gates pass:

Gate	Owner
Functional correctness	Verification Agent
User intent alignment	Verification Agent
Tests passing	Verification Agent
Code hygiene	Slop Agent
Structural sanity	Architecture Agent
UI polish	UI Agent

If any gate fails → loop continues.

⸻

7. Cost Pressure (Yet-Another-Theory-of-Agency)

To avoid lazy looping:
	•	Each iteration increments a cost counter
	•	Cost is surfaced to agents in prompts
	•	Agents are told:
“Iteration is expensive. Fix holistically.”

Optional policies:
	•	Soft iteration budgets
	•	Escalation to architecture agent when thrashing detected
	•	Loop refusal if regression increases cost

The system feels consequences.

⸻

8. Loop Exit Conditions

The Primary Agent may ask to exit only if:
	•	All verification gates pass
	•	No open architectural warnings
	•	UI agent reports no deltas
	•	Execution agent confirms real user flows succeed

The Trunk Loop independently validates this before stopping.

⸻

9. Execution Environment
	•	Local-first
	•	macOS primary target
	•	Cross-platform in principle
	•	Sandbox execution (container / jailed workspace)
	•	Agents have full access inside the sandbox

⸻

10. Framework Philosophy

Only use:
	•	Actively maintained
	•	Forward-moving
	•	Opinionated enough to constrain chaos

Why:
	•	Constraints reduce agent error
	•	Modern frameworks encode best practices
	•	Stale stacks amplify entropy

⸻

11. Failure Definition

This system fails if:
	•	It exits early
	•	It delivers “mostly working”
	•	It asks the user to finish things
	•	It cannot enforce correctness autonomously

⸻

12. Mental Model (TL;DR)
	•	The loop is god
	•	Primary Agent is law
	•	Verification Agent is reality
	•	Specialists are critics
	•	Cost creates agency
	•	Nothing ends until it’s actually right

If you want, next we can:
	•	Reduce this to a literal folder + script layout
	•	Write the bash loop
	•	Design the inter-agent protocol
	•	Map this onto your existing local model stack

Just say which layer you want to descend into.

Got it. I was really hoping your original report would include recommended implementation specifics like recommended frameworks, algorithms, etc. Can you do that now?

Perfect — here is a tight, operational, build-this-now spec.
No prose, no marketing, no philosophy. Just what to use, where, and why.

⸻

Ralph Wiggum System — Implementation Spec (Operational)

0. Non-Negotiables Recap
	•	Local only
	•	No Docker
	•	Rust-first (Python only where unavoidable, no PyO3)
	•	LM Studio preferred
	•	mlx-vlm only if LM Studio insufficient
	•	Open WebUI or Vue frontend
	•	Fully autonomous or bust

⸻

1. Trunk Loop (Supervisor)

Language
	•	Bash + Rust binary

Why
	•	Bash = brutally reliable control loop
	•	Rust = state machine, invariants, logging, enforcement

Structure

./wiggum/
  run.sh              # infinite loop
  supervisor/         # Rust binary
  state/              # JSON + logs
  workspace/          # mutable codebase

run.sh

while true; do
  ./supervisor tick || exit 1
done

No exit unless explicitly approved by supervisor.

⸻

2. Supervisor (Primary Agent)

Language
	•	Rust

Libraries
	•	tokio – async orchestration
	•	serde_json – state + reports
	•	reqwest – LLM calls
	•	uuid – iteration IDs
	•	notify – filesystem changes

Responsibilities
	•	Own user intent (immutable)
	•	Own task graph
	•	Dispatch agents
	•	Enforce gates
	•	Deny premature exit

State Files

state/
  intent.json
  tasks.json
  iteration.log
  cost.json


⸻

3. LLM Backend (Inference)

Preferred (90% of cases)

LM Studio local server
	•	Engine: MLX
	•	API: OpenAI-compatible
	•	Endpoint: http://localhost:1234/v1/chat/completions

Supervisor calls it directly via HTTP.

When NOT sufficient

Only if you need:
	•	Custom decoding loops
	•	Vision pipeline hacks
	•	Training / fine-tuning

Then:

Fallback

Python MLX-VLM microservice
	•	Framework: FastAPI
	•	Models: LLaVA / Qwen-VL / Gemma-VL
	•	Runs as separate process
	•	Rust talks via HTTP
	•	Python never embedded

⸻

4. Agent Execution Model

Agents are prompts + tools, not processes

Supervisor invokes them by:
	•	Sending prompt → LLM
	•	Running local tools
	•	Interpreting structured output

⸻

5. Agents (Concrete)

5.1 Execution Verification Agent (Truth)

Tools
	•	pnpm test / bun test
	•	playwright test
	•	curl for APIs

Definition of Done
	•	App starts
	•	Critical flows succeed
	•	Tests green

If fail → loop continues

⸻

5.2 Code Slop Agent (Entropy Control)

Tools
	•	eslint
	•	biome
	•	tsc
	•	clippy (if Rust target code)

Checks
	•	Duplication
	•	File size
	•	Cyclomatic complexity
	•	Dead code

Outputs refactor instructions only.

⸻

5.3 Architecture Agent (Shape Control)

Triggered when
	•	N slop findings
	•	Files > X LOC
	•	Repeated patterns detected

Actions
	•	Propose module boundaries
	•	Split subsystems
	•	Introduce interfaces

Never changes behavior.

⸻

5.4 UI Snob Agent (Aesthetics)

Tools
	•	Playwright screenshots
	•	DOM inspection
	•	CSS box metrics

Checks
	•	Alignment
	•	Spacing
	•	Responsiveness
	•	Interaction affordances

Blocks completion on “almost”.

⸻

6. Cost Pressure (Agency)

Mechanism

Supervisor maintains:

cost.json {
  "iterations": 17,
  "llm_tokens": 41230,
  "failures": 6
}

Injected into every prompt:

“Iteration is expensive. Fix holistically.”

Escalation Rules
	•	Repeated failures → Architecture Agent
	•	Regression → Slop Agent mandatory
	•	Thrashing → prompt tightening

No artificial stop unless max-iterations hit (hard safety).

⸻

7. Output App Stack (Fresh, Opinionated)

Default Full-Stack
	•	Frontend: Vue 3 + Vite
	•	Backend: Node 20 + TypeScript
	•	Runtime: Bun preferred
	•	DB: SQLite / Turso
	•	Tests: Vitest + Playwright

Why
	•	Fast
	•	Opinionated
	•	Agent-friendly
	•	Minimal magic

⸻

8. Frontend for the Agents

Option A (Fastest)

Open WebUI (pip install)
	•	Point at LM Studio
	•	Supports images
	•	Zero UI work

Option B (Controlled)

Vue 3 dashboard
	•	Shows:
	•	Current task
	•	Agent reports
	•	Cost counters
	•	Loop state

Supervisor exposes /state endpoint.

⸻

9. Loop Exit Conditions (Hard)

Supervisor exits only if:
	•	Verification Agent: PASS
	•	Slop Agent: CLEAN
	•	Architecture Agent: NO WARNINGS
	•	UI Agent: NO DELTAS
	•	No regressions vs intent

Otherwise: loop continues.

⸻

10. Minimal Build Order
	1.	LM Studio server
	2.	Rust supervisor skeleton
	3.	Bash loop
	4.	Execution agent + tests
	5.	Slop agent
	6.	Architecture agent
	7.	UI agent
	8.	Cost pressure
	9.	UI (optional)

⸻

11. Mental Model (One Line)

The supervisor doesn’t trust the model.
It trusts reality.

If you want next:
	•	Rust supervisor code skeleton
	•	Exact OpenAI request schema
	•	Prompt templates per agent
	•	State machine diagram

Say the word.