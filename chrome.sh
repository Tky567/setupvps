#!/bin/bash

# Puppeteer Chrome Fix for GitHub Codespaces (Optimized)
# Author: Assistant
# Description: Auto-setup Chrome/Chromium for Puppeteer in Codespaces with sudo access

set -e  # Exit on any error

echo "🚀 Puppeteer Chrome Setup for GitHub Codespaces"
echo "==============================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to find Chrome/Chromium executable
find_browser() {
    local browsers=(
        "/usr/bin/google-chrome"
        "/usr/bin/google-chrome-stable"
        "/usr/bin/chromium"
        "/usr/bin/chromium-browser"
        "/opt/google/chrome/chrome"
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    )
    
    for browser in "${browsers[@]}"; do
        if [ -f "$browser" ]; then
            echo "$browser"
            return 0
        fi
    done
    return 1
}

# Step 1: Check if Chrome/Chromium is already installed
echo "🔍 Step 1: Checking for existing Chrome/Chromium..."
BROWSER_PATH=$(find_browser)

if [ $? -eq 0 ]; then
    echo "✅ Found browser at: $BROWSER_PATH"
else
    echo "❌ No browser found. Attempting to install..."
    
    # Step 2: Try to install Chrome (if we have permissions)
    echo "🔧 Step 2: Attempting to install Google Chrome..."
    
    # GitHub Codespaces has sudo with nopasswd by default
    echo "📦 Installing Chrome (Codespaces has sudo access)..."
    
    # Install Chrome directly
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
        
        BROWSER_PATH=$(find_browser)
        if [ $? -eq 0 ]; then
            echo "✅ Chrome installed successfully at: $BROWSER_PATH"
        else
            echo "⚠️ Chrome installation completed but executable not found in expected locations"
            # Try to find it in alternative locations
            CHROME_ALT=$(which google-chrome-stable 2>/dev/null || which google-chrome 2>/dev/null)
            if [ -n "$CHROME_ALT" ]; then
                BROWSER_PATH="$CHROME_ALT"
                echo "✅ Found Chrome at: $BROWSER_PATH"
            fi
        fi
    
    # Step 3: Fallback to Puppeteer's bundled Chromium if Chrome install failed
    if [ -z "$BROWSER_PATH" ]; then
        echo "🔧 Step 3: Trying Puppeteer's bundled Chromium as fallback..."
        
        # Try installing Chrome via Puppeteer
        if command_exists npx; then
            echo "📦 Installing Chrome via Puppeteer (this may take a moment)..."
            npx puppeteer browsers install chrome
            
            # Check Puppeteer cache directories
            PUPPETEER_DIRS=(
                "$HOME/.cache/puppeteer"
                "$HOME/.local/share/puppeteer"
                "node_modules/puppeteer/.local-chromium"
                "./node_modules/puppeteer/.local-chromium"
            )
            
            for dir in "${PUPPETEER_DIRS[@]}"; do
                if [ -d "$dir" ]; then
                    CHROMIUM_PATH=$(find "$dir" -name "chrome" -type f -executable 2>/dev/null | head -1)
                    if [ -n "$CHROMIUM_PATH" ]; then
                        BROWSER_PATH="$CHROMIUM_PATH"
                        echo "✅ Found Puppeteer Chromium at: $BROWSER_PATH"
                        break
                    fi
                fi
            done
        else
            echo "❌ npx not available"
        fi
    fi
fi

# Step 4: Create configuration files
echo "⚙️  Step 4: Creating configuration files..."

# Create environment configuration
cat > .env.puppeteer << EOF
# Puppeteer Configuration for GitHub Codespaces
PUPPETEER_EXECUTABLE_PATH=$BROWSER_PATH
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
EOF

# Create Node.js configuration file
cat > puppeteer.config.js << EOF
// Puppeteer configuration for GitHub Codespaces
const puppeteer = require('puppeteer');

const launchOptions = {
  headless: true,
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-extensions',
    '--disable-gpu',
    '--disable-background-timer-throttling',
    '--disable-backgrounding-occluded-windows',
    '--disable-renderer-backgrounding',
    '--remote-debugging-port=9222',
    '--no-first-run',
    '--no-default-browser-check'
  ]
};

// Add executable path if found
if ('$BROWSER_PATH') {
  launchOptions.executablePath = '$BROWSER_PATH';
}

module.exports = {
  launch: () => puppeteer.launch(launchOptions),
  launchOptions
};
EOF

# Create example usage file
cat > puppeteer-example.js << EOF
// Example usage of Puppeteer in GitHub Codespaces
const config = require('./puppeteer.config.js');

async function testPuppeteer() {
  try {
    console.log('🚀 Launching browser...');
    const browser = await config.launch();
    
    console.log('📄 Creating new page...');
    const page = await browser.newPage();
    
    console.log('🌐 Navigating to example.com...');
    await page.goto('https://example.com');
    
    console.log('📸 Taking screenshot...');
    await page.screenshot({ path: 'example.png' });
    
    console.log('🔍 Getting page title...');
    const title = await page.title();
    console.log('Page title:', title);
    
    console.log('🔒 Closing browser...');
    await browser.close();
    
    console.log('✅ Test completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run test if this file is executed directly
if (require.main === module) {
  testPuppeteer();
}

module.exports = { testPuppeteer };
EOF

# Step 5: Set up package.json scripts (if exists)
if [ -f "package.json" ]; then
    echo "📝 Step 5: Updating package.json scripts..."
    
    # Backup original package.json
    cp package.json package.json.backup
    
    # Add test script using Node.js (since jq might not be available)
    node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    if (!pkg.scripts) pkg.scripts = {};
    pkg.scripts['test-puppeteer'] = 'node puppeteer-example.js';
    pkg.scripts['puppeteer-test'] = 'node puppeteer-example.js';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    " 2>/dev/null || echo "⚠️  Could not update package.json (Node.js required)"
fi

# Step 6: Final verification
echo "🔍 Step 6: Final verification..."

if [ -n "$BROWSER_PATH" ] && [ -f "$BROWSER_PATH" ]; then
    echo "✅ Browser found: $BROWSER_PATH"
    
    # Test browser version
    BROWSER_VERSION=$("$BROWSER_PATH" --version 2>/dev/null || echo "Unknown")
    echo "📊 Browser version: $BROWSER_VERSION"
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo "=================================================="
    echo "📁 Files created:"
    echo "  • .env.puppeteer - Environment variables"
    echo "  • puppeteer.config.js - Puppeteer configuration"
    echo "  • puppeteer-example.js - Example usage"
    echo ""
    echo "🚀 To test Puppeteer, run:"
    echo "  node puppeteer-example.js"
    echo ""
    echo "💡 To use in your code:"
    echo "  const config = require('./puppeteer.config.js');"
    echo "  const browser = await config.launch();"
    echo ""
    echo "🔧 Environment variable set:"
    echo "  PUPPETEER_EXECUTABLE_PATH=$BROWSER_PATH"
    
else
    echo "❌ Setup failed: No browser executable found"
    echo "=================================================="
    echo "🔧 Manual steps to try:"
    echo "1. Install Chrome manually:"
    echo "   wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
    echo "   echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list"
    echo "   sudo apt update && sudo apt install -y google-chrome-stable"
    echo ""
    echo "2. Use Puppeteer's bundled Chromium:"
    echo "   npx puppeteer browsers install chrome"
    echo ""
    echo "3. Check .devcontainer/devcontainer.json for Chrome feature"
fi

echo "=================================================="