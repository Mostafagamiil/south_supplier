import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const fcm = admin.messaging();

exports.checkHilth = functions.https.onCall(async (data, context) => {
  return "the function is working";
});

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const title = data.title;
  const body = data.body;
  const token = data.token;

  try {
    const payload = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: {
        body: body,
      },
    };

    return fcm.send(payload).then((response) => {
      return {success: true, response: "Successfully sent message" + response};
    }).catch((error) => {
      return {error: error};
    });
  } catch (error) {
    throw new functions.https.HttpsError("unknown", "error" + error);
  }
});
