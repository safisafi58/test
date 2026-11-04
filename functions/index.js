const { onValueCreated } = require("firebase-functions/v2/database");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.notifyNewPrompt = onValueCreated(
  { ref: "/prompts/{promptId}", region: "us-central1" },
  async (event) => {
    const prompt = event.data.val() || {};
    const title = String(prompt.title || "New PromptGo post").slice(0, 90);
    const category = String(prompt.category || "New prompt").slice(0, 70);
    await getMessaging().send({
      topic: "promptgo_new_posts",
      notification: {
        title: "New PromptGo post",
        body: title + " • " + category,
      },
      data: {
        promptId: String(event.params.promptId),
        type: "new_prompt",
      },
      android: {
        priority: "high",
        notification: { channelId: "promptgo_posts" },
      },
    });
  }
);
