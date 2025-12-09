# Notion Integration Guide - NORION Whitepaper Publishing

## Quick Start (5 minutes)

### Option 1: Automated Integration (API)

**Prerequisites:**
1. Notion account (free or paid)
2. Notion API key

**Steps:**

```bash
# 1. Create Notion integration
# Go to: https://www.notion.so/my-integrations
# Click "Create new integration"
# Name it "Veil Hub Whitepaper"
# Copy the API key

# 2. Set environment variables
export NOTION_API_KEY="your_api_key_here"
export NOTION_PAGE_ID="your_page_id_here"  # Get from page URL

# 3. Run the integration script
cd /workspaces/veil_hub
bash notion-whitepaper-integration.sh

# 4. Share your Notion page with the integration
# In Notion: Click "Share" → Add the integration as a guest
```

### Option 2: Manual Copy-Paste (1 minute)

**Fastest method:**

```bash
# 1. Copy whitepaper to clipboard
cat /workspaces/veil_hub/NORION-WHITEPAPER.md | xclip -selection clipboard

# 2. In Notion:
#    - Create new page
#    - Type "/code"
#    - Select "Code block"
#    - Paste content
#    - Change language to "markdown"
```

### Option 3: File Upload (Sync)

**For keeping Notion in sync with repo:**

```bash
# 1. Export as markdown from repo
cat /workspaces/veil_hub/NORION-WHITEPAPER.md

# 2. In Notion:
#    - Click three dots menu
#    - Select "Export"
#    - Can import markdown files
```

---

## How to Get Your Notion IDs

### Find Your Page ID

From Notion page URL: `https://www.notion.so/workspaceid/YOUR_PAGE_ID?v=...`

Extract the `YOUR_PAGE_ID` (32 characters before the `?`)

### Get API Key

1. Visit: https://www.notion.so/my-integrations
2. Click "Create new integration"
3. Fill in name: `Veil Hub API`
4. Select capability: `Insert content`
5. Click "Submit"
6. Copy the "Internal Integration Token" (starts with `secret_`)

---

## Whitepaper Content

**File:** `/workspaces/veil_hub/NORION-WHITEPAPER.md`

**Size:** 549 lines

**Key Sections:**
- Executive Summary
- Problem Statement
- Protocol Architecture
- Revenue Models ($280.5M annually @ $3B TVL)
- Smart Contract Modules (18 audited)
- Economic Sustainability
- Competitive Analysis
- Risk Assessment
- Implementation Timeline

---

## Verification

After publishing to Notion:

```bash
# 1. Check whitepaper file exists
ls -lh /workspaces/veil_hub/NORION-WHITEPAPER.md

# 2. Verify content
head -20 /workspaces/veil_hub/NORION-WHITEPAPER.md

# 3. Test API integration
curl -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: 2022-06-28" \
     https://api.notion.com/v1/pages/$NOTION_PAGE_ID
```

---

## Troubleshooting

### "API Key not found"
```bash
# Check if variable is set
echo $NOTION_API_KEY

# Verify it starts with "secret_"
if [[ $NOTION_API_KEY == secret_* ]]; then echo "Valid"; else echo "Invalid"; fi
```

### "Page not found" (404)
- Verify you added the integration to your Notion workspace
- Check page is shared with the integration (not just privately)
- Confirm page ID is correct (32 chars without dashes)

### "Unauthorized" (401)
- API key is incorrect or expired
- Go back to https://www.notion.so/my-integrations and regenerate

### Manual Copy Failed
- Make sure `xclip` is installed: `apt install xclip`
- Or use: `cat /workspaces/veil_hub/NORION-WHITEPAPER.md | wl-copy` (Wayland)

---

## Integration Files

- **Script:** `/workspaces/veil_hub/notion-whitepaper-integration.sh`
- **Whitepaper:** `/workspaces/veil_hub/NORION-WHITEPAPER.md`
- **This Guide:** `/workspaces/veil_hub/NOTION_INTEGRATION.md`

---

## Next Steps

After publishing whitepaper to Notion:

1. ✅ Supra CLI running (container: `supra_cli`)
2. ✅ Frontend deployed (10/10 pages)
3. ✅ Whitepaper in Notion
4. ⏳ Deploy contracts to testnet
5. ⏳ Verify on Supra chain (chain ID: 6)

**Deploy contracts:**
```bash
bash /workspaces/veil_hub/scripts/init-supra-account.sh accountA testnet
docker exec supra_cli supra move tool compile --package-dir /workspace/supra/move_workspace/VeilHub
docker exec supra_cli supra move tool publish --package-dir /workspace/supra/move_workspace/VeilHub --rpc-url https://rpc-testnet.supra.com
```

---

**Created:** $(date +'%Y-%m-%d')
**Whitepaper Status:** Ready for Notion integration
**Supra CLI Status:** ✅ Running
**Frontend Status:** ✅ Deployed (10/10 pages, ESLint clean)
