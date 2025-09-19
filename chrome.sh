#!/bin/bash

# Puppeteer Chrome Installer for GitHub Codespaces
# Author: Assistant
# Description: Force install Chrome by all possible methods for Puppeteer

set -e  # Exit on any error

echo "🚀 Installing Chrome for Puppeteer in GitHub Codespaces"
echo "======================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Initialize browser path variable
BROWSER_PATH=""

echo "📦 Method 1: Installing Google Chrome via APT..."
echo "----------------------------------------"

# Install Chrome via APT (primary method)
echo "🔧 Adding Google Chrome repository..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

echo "🔄 Updating package list..."
sudo apt update

echo "⬇️ Installing Google Chrome..."
sudo apt install -y google-chrome-stable

# Find Chrome after installation
CHROME_PATHS=(
    "/usr/bin/google-chrome"
    "/usr/bin/google-chrome-stable"
    "/opt/google/chrome/chrome"
)

for path in "${CHROME_PATHS[@]}"; do
    if [ -f "$path" ]; then
        BROWSER_PATH="$path"
        echo "✅ Found Chrome at: $BROWSER_PATH"
        break
    fi
done

# If Chrome not found, try which command
if [ -z "$BROWSER_PATH" ]; then
    BROWSER_PATH=$(which google-chrome-stable 2>/dev/null || which google-chrome 2>/dev/null || echo "")
    if [ -n "$BROWSER_PATH" ]; then
        echo "✅ Found Chrome via which: $BROWSER_PATH"
    fi
fi

echo ""
echo "📦 Method 2: Installing Chrome via Puppeteer..."
echo "-----------------------------------------------"

# Force install via Puppeteer (backup method)
if command_exists npm; then
    echo "🔧 Installing puppeteer if not present..."
    npm install puppeteer --save-dev 2>/dev/null || npm install puppeteer -g 2>/dev/null || echo "⚠️ NPM install failed"
fi

if command_exists npx; then
    echo "⬇️ Installing Chrome via Puppeteer..."
    npx puppeteer browsers install chrome --path ./browsers 2>/dev/null || npx puppeteer browsers install chrome 2>/dev/null || echo "⚠️ Puppeteer install failed"
    
    # Find Puppeteer Chrome
    PUPPETEER_DIRS=(
        "./browsers"
        "$HOME/.cache/puppeteer"
        "$HOME/.local/share/puppeteer"
        "node_modules/puppeteer/.local-chromium"
        "./node_modules/puppeteer/.local-chromium"
        "/tmp/puppeteer_dev_chrome_profile"
    )
    
    echo "🔍 Searching for Puppeteer Chrome..."
    for dir in "${PUPPETEER_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            PUPPETEER_CHROME=$(find "$dir" -name "chrome" -type f -executable 2>/dev/null | head -1)
            if [ -n "$PUPPETEER_CHROME" ] && [ -z "$BROWSER_PATH" ]; then
                BROWSER_PATH="$PUPPETEER_CHROME"
                echo "✅ Found Puppeteer Chrome at: $BROWSER_PATH"
                break
            fi
        fi
    done
fi

echo ""
echo "📦 Method 3: Installing Chromium as fallback..."
echo "-----------------------------------------------"

# Install Chromium as additional fallback
echo "⬇️ Installing Chromium browser..."
sudo apt install -y chromium-browser 2>/dev/null || sudo apt install -y chromium 2>/dev/null || echo "⚠️ Chromium install failed"

# Find Chromium
CHROMIUM_PATHS=(
    "/usr/bin/chromium-browser"
    "/usr/bin/chromium"
    "/snap/bin/chromium"
)

CHROMIUM_PATH=""
for path in "${CHROMIUM_PATHS[@]}"; do
    if [ -f "$path" ]; then
        CHROMIUM_PATH="$path"
        echo "✅ Found Chromium at: $CHROMIUM_PATH"
        break
    fi
done

# Use Chromium if Chrome not found
if [ -z "$BROWSER_PATH" ] && [ -n "$CHROMIUM_PATH" ]; then
    BROWSER_PATH="$CHROMIUM_PATH"
    echo "✅ Using Chromium as Chrome alternative: $BROWSER_PATH"
fi

echo ""
echo "📦 Method 4: Downloading Chrome directly..."
echo "------------------------------------------"

# Download Chrome directly if all else fails
if [ -z "$BROWSER_PATH" ]; then
    echo "⬇️ Downloading Chrome directly..."
    mkdir -p /tmp/chrome-download
    cd /tmp/chrome-download
    
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb 2>/dev/null || sudo apt-get install -f -y
    
    # Check again after direct install
    for path in "${CHROME_PATHS[@]}"; do
        if [ -f "$path" ]; then
            BROWSER_PATH="$path"
            echo "✅ Chrome installed via direct download: $BROWSER_PATH"
            break
        fi
    done
    
    cd - > /dev/null
    rm -rf /tmp/chrome-download
fi

echo ""
echo "⚙️ Creating configuration files..."
echo "==================================="

# Determine final browser path
FINAL_BROWSER_PATH="$BROWSER_PATH"
if [ -z "$FINAL_BROWSER_PATH" ]; then
    # Last resort - try to find any browser
    FINAL_BROWSER_PATH=$(which google-chrome-stable 2>/dev/null || which google-chrome 2>/dev/null || which chromium-browser 2>/dev/null || which chromium 2>/dev/null || echo "/usr/bin/google-chrome-stable")
    echo "⚠️ Using fallback path: $FINAL_BROWSER_PATH"
fi

# Create environment configuration
cat > .env.puppeteer << EOF
# Puppeteer Configuration for GitHub Codespaces
PUPPETEER_EXECUTABLE_PATH=$FINAL_BROWSER_PATH
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
EOF

echo "✅ Created .env.puppeteer"

# Create Node.js configuration file
cat > puppeteer.config.js << EOF
// Puppeteer configuration for GitHub Codespaces
const puppeteer = require('puppeteer');

const launchOptions = {
  executablePath: '$FINAL_BROWSER_PATH',
  headless: true,
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-extensions',
    '--disable-gpu',
    '--disable-web-security',
    '--disable-features=VizDisplayCompositor',
    '--disable-background-timer-throttling',
    '--disable-backgrounding-occluded-windows',
    '--disable-renderer-backgrounding',
    '--disable-ipc-flooding-protection',
    '--remote-debugging-port=9222',
    '--no-first-run',
    '--no-default-browser-check',
    '--memory-pressure-off',
    '--max_old_space_size=4096'
  ]
};

module.exports = {
  launch: () => puppeteer.launch(launchOptions),
  launchOptions
};
EOF

echo "✅ Created puppeteer.config.js"

# Create test file
cat > puppeteer-test.js << EOF
// Test Puppeteer setup in GitHub Codespaces
const config = require('./puppeteer.config.js');

async function testPuppeteer() {
  console.log('🚀 Testing Puppeteer setup...');
  
  try {
    console.log('📍 Browser path:', config.launchOptions.executablePath);
    
    console.log('🔧 Launching browser...');
    const browser = await config.launch();
    
    console.log('📄 Creating new page...');
    const page = await browser.newPage();
    
    console.log('🌐 Testing navigation...');
    await page.goto('https://httpbin.org/json', { waitUntil: 'networkidle0' });
    
    console.log('📊 Getting page info...');
    const title = await page.title();
    const url = await page.url();
    
    console.log('✅ Page title:', title);
    console.log('✅ Page URL:', url);
    
    console.log('📸 Taking screenshot...');
    await page.screenshot({ path: 'test-screenshot.png', fullPage: true });
    
    console.log('🔒 Closing browser...');
    await browser.close();
    
    console.log('🎉 SUCCESS! Puppeteer is working correctly!');
    console.log('📸 Screenshot saved as: test-screenshot.png');
    
  } catch (error) {
    console.error('❌ ERROR:', error.message);
    console.error('🔍 Full error:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  testPuppeteer();
}

module.exports = { testPuppeteer };
EOF

echo "✅ Created puppeteer-test.js"

# Update package.json if exists
if [ -f "package.json" ]; then
    echo "📝 Updating package.json..."
    node -e "
    try {
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      if (!pkg.scripts) pkg.scripts = {};
      pkg.scripts['test:puppeteer'] = 'node puppeteer-test.js';
      pkg.scripts['puppeteer:test'] = 'node puppeteer-test.js';
      fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
      console.log('✅ Updated package.json with test scripts');
    } catch (e) {
      console.log('⚠️ Could not update package.json:', e.message);
    }
    " || echo "⚠️ Could not update package.json"
fi

echo ""
echo "🔍 Final verification..."
echo "======================="

# Test browser executable
if [ -f "$FINAL_BROWSER_PATH" ]; then
    echo "✅ Browser executable found: $FINAL_BROWSER_PATH"
    
    # Get browser version
    BROWSER_VERSION=$("$FINAL_BROWSER_PATH" --version 2>/dev/null || echo "Version unknown")
    echo "📊 Browser version: $BROWSER_VERSION"
    
    echo ""
    echo "🎉 INSTALLATION COMPLETED SUCCESSFULLY!"
    echo "======================================"
    echo ""
    echo "📁 Files created:"
    echo "  • .env.puppeteer - Environment variables"
    echo "  • puppeteer.config.js - Puppeteer configuration"
    echo "  • puppeteer-test.js - Test script"
    echo ""
    echo "🧪 To test your setup:"
    echo "  node puppeteer-test.js"
    echo ""
    echo "💻 To use in your code:"
    echo "  const config = require('./puppeteer.config.js');"
    echo "  const browser = await config.launch();"
    echo ""
    echo "🔧 Browser configured:"
    echo "  Path: $FINAL_BROWSER_PATH"
    echo "  Version: $BROWSER_VERSION"
    
else
    echo "⚠️ WARNING: Browser executable not found at expected path"
    echo "📍 Configured path: $FINAL_BROWSER_PATH"
    echo "🔧 You may need to adjust the path in puppeteer.config.js"
fi

echo ""
echo "🚀 Ready to use Puppeteer in GitHub Codespaces!"
echo "==============================================="