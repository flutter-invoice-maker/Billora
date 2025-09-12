# AI Integration Setup Guide

## OpenAI API Setup

To enable AI features in Billora, you need to set up your OpenAI API key:

### 1. Get OpenAI API Key
- Go to [OpenAI Platform](https://platform.openai.com/api-keys)
- Create a new API key
- Copy the key (starts with `sk-proj-...`)

### 2. Create .env File
Create a `.env` file in the project root with the following content:

```env
OPENAI_API_KEY=your_actual_api_key_here
```

Replace `your_actual_api_key_here` with your actual OpenAI API key.

### 3. Security Notes
- The `.env` file is already in `.gitignore` for security
- Never commit your API key to version control
- Keep your API key secure and don't share it

### 4. AI Features
Once configured, you'll have access to:
- **Floating AI Button**: Available on all main screens
- **Contextual AI Assistant**: Provides insights based on your business data
- **Streaming Responses**: Real-time AI responses
- **User-Specific Analysis**: AI analyzes only your data
- **Smart Suggestions**: Invoice categorization, customer insights, etc.

### 5. Testing
- Run the app after setting up the `.env` file
- Look for the floating AI button with sparkle icon
- Check console logs for initialization messages
- If the API key is missing, the app will still run but AI features will be disabled

### 6. Models Used
- Default: `gpt-3.5-turbo` (cost-effective)
- Supports both streaming and non-streaming responses
- Context includes your invoices, customers, and products data

### 7. Troubleshooting
- If AI button is not visible, check console logs
- Ensure `.env` file is in the project root
- Verify API key format is correct
- Check internet connection for API calls

















