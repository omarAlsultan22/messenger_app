// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

admin.initializeApp();

// 🔑 هذا المفتاح تحصل عليه من Google AI Studio مجاناً
const GEMINI_API_KEY = functions.config().gemini?.api_key || 'AQ.Ab8RN6LeoBz3BWc6Nzpg-3TWEMtnfR21xFlSrdOUeeUse4RVxg';

exports.generateAIResponse = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        const data = snap.data();

        if (data.senderId === 'ai') return null;

        const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
        const model = genAI.getGenerativeModel({ model: 'gemini-3.5-flash' });

        const prompt = `
            You are a friend named ${data.friendName}.
            Personality: ${data.personality}
            User message: ${data.text}
            Reply in a natural conversational way.
        `;

        const result = await model.generateContent(prompt);
        const response = result.response.text();

        await snap.ref.update({
            response: response,
            senderId: 'ai',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        return null;
    });