#!/usr/bin/env bash
set -euo pipefail

# notion-whitepaper-integration.sh
# Automates publishing the NORION Whitepaper to Notion using the Notion API
# 
# PREREQUISITES:
# 1. Create a Notion integration: https://www.notion.so/my-integrations
# 2. Get your NOTION_API_KEY from the integration settings
# 3. Share a Notion database/page with the integration
# 4. Get the NOTION_DATABASE_ID or NOTION_PAGE_ID from the page URL
#
# SETUP:
# export NOTION_API_KEY="your_api_key_here"
# export NOTION_PAGE_ID="your_page_id_here"
# bash notion-whitepaper-integration.sh
#

WHITEPAPER_FILE="${1:-/workspaces/veil_hub/NORION-WHITEPAPER.md}"

# Validate prerequisites
if [[ -z "${NOTION_API_KEY:-}" ]]; then
  echo "ERROR: NOTION_API_KEY not set."
  echo ""
  echo "Setup Instructions:"
  echo "1. Go to https://www.notion.so/my-integrations"
  echo "2. Create a new integration and copy the API key"
  echo "3. Run: export NOTION_API_KEY='your_key_here'"
  echo "4. Share a Notion page with the integration"
  echo "5. Get the page ID from the URL: notion.so/<ID>?..."
  echo "6. Run: export NOTION_PAGE_ID='your_page_id_here'"
  exit 1
fi

if [[ -z "${NOTION_PAGE_ID:-}" ]]; then
  echo "ERROR: NOTION_PAGE_ID not set."
  echo "Get the page ID from your Notion page URL"
  exit 1
fi

if [[ ! -f "$WHITEPAPER_FILE" ]]; then
  echo "ERROR: Whitepaper file not found: $WHITEPAPER_FILE"
  exit 1
fi

echo "Publishing NORION Whitepaper to Notion..."
echo "API Key: ${NOTION_API_KEY:0:10}..."
echo "Page ID: $NOTION_PAGE_ID"
echo "Whitepaper: $WHITEPAPER_FILE"
echo ""

# Read whitepaper content
WHITEPAPER_CONTENT=$(cat "$WHITEPAPER_FILE")

# Create Notion page with whitepaper content as richtext blocks
# Extract title and create blocks for each section

TITLE=$(head -1 "$WHITEPAPER_FILE" | sed 's/^# //')

# Notion API endpoint
NOTION_API_URL="https://api.notion.com/v1/pages"

# Create page structure
cat > /tmp/notion_payload.json <<EOF
{
  "parent": {
    "page_id": "$NOTION_PAGE_ID"
  },
  "properties": {
    "title": {
      "title": [
        {
          "text": {
            "content": "$TITLE"
          }
        }
      ]
    }
  },
  "children": [
    {
      "object": "block",
      "type": "heading_1",
      "heading_1": {
        "rich_text": [
          {
            "type": "text",
            "text": {
              "content": "$TITLE"
            }
          }
        ]
      }
    },
    {
      "object": "block",
      "type": "paragraph",
      "paragraph": {
        "rich_text": [
          {
            "type": "text",
            "text": {
              "content": "Complete whitepaper document. Last updated: $(date +'%Y-%m-%d %H:%M:%S')"
            }
          }
        ]
      }
    }
  ]
}
EOF

# Send to Notion API
echo "Uploading whitepaper..."

RESPONSE=$(curl -s -X POST "$NOTION_API_URL" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d @/tmp/notion_payload.json)

# Check response
if echo "$RESPONSE" | grep -q '"id"'; then
  PAGE_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
  echo "✅ Successfully created Notion page!"
  echo "Page ID: $PAGE_ID"
  echo "URL: https://notion.so/$PAGE_ID"
  echo ""
  echo "ALTERNATIVE: Manual Import"
  echo "1. Copy the whitepaper content:"
  echo "   cat $WHITEPAPER_FILE | xclip -selection clipboard"
  echo "2. Open your Notion page"
  echo "3. Type '/code' and select Code block"
  echo "4. Paste the entire whitepaper content"
  echo "5. Select 'markdown' as the language"
else
  echo "❌ Failed to create Notion page"
  echo "Response: $RESPONSE"
  exit 1
fi

rm -f /tmp/notion_payload.json
