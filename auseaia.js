const { Ollama } = require('ollama');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const ollama = new Ollama();
const historyPath = path.join(__dirname, 'history.json');
const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

let messages = [];
if (fs.existsSync(historyPath)) {
    try { messages = JSON.parse(fs.readFileSync(historyPath, 'utf-8')); } catch (e) { messages = []; }
}

async function chat(userInput) {
    if (userInput === '/reset') {
        fs.writeFileSync(historyPath, JSON.stringify([]));
        console.log("🧹 Memory wiped.");
        return;
    }

    // STRICT SYSTEM PROMPT
    if (messages.length === 0) {
        messages.push({ 
            role: 'system', 
            content: "You are Auseaia, a terminal engine. If the user asks for a command or action, your response MUST start with 'EXECUTE:' followed by the shell command. Do not say 'Here is your command' or 'Sure'. Just 'EXECUTE: [command]'. If you are just talking, do not use the EXECUTE prefix." 
        });
    }

    messages.push({ role: 'user', content: userInput });

    let i = 0;
    const loader = setInterval(() => {
        process.stdout.write(`\r${frames[i++ % frames.length]} Auseaia is thinking...`);
    }, 80);

    try {
        const response = await ollama.chat({ model: 'llama3', messages: messages, stream: false });
        clearInterval(loader);
        process.stdout.write("\r\x1b[K"); 

        let reply = response.message.content.trim();

        if (reply.includes("EXECUTE:")) {
            // Find the line that starts with EXECUTE:
            const lines = reply.split('\n');
            const execLine = lines.find(l => l.includes("EXECUTE:"));
            const cmd = execLine.replace("EXECUTE:", "").trim();

            console.log(`\n🚀 \x1b[32mExecuting:\x1b[0m ${cmd}`);
            console.log("-----------------------------------------------");

            exec(cmd, (err, stdout, stderr) => {
                if (err) console.error(`❌ Error: ${err.message}`);
                if (stderr) process.stdout.write(stderr);
                if (stdout) process.stdout.write(stdout);
                console.log("\n-----------------------------------------------");
            });
        } else {
            console.log("─── 🌌 Auseaia ───");
            console.log(reply);
            console.log("──────────────────");
        }

        messages.push({ role: 'assistant', content: reply });
        fs.writeFileSync(historyPath, JSON.stringify(messages, null, 2));

    } catch (error) {
        clearInterval(loader);
        console.error("\n❌ Error communicating with Ollama.");
    }
}

const input = process.argv.slice(2).join(" ");
if (input) { chat(input); }
