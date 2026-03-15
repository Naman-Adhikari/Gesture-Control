import cv2
import time
import subprocess
import mediapipe as mp
from mediapipe.tasks.python import vision
from mediapipe.tasks import python


def get_fingers_up(hand):
    fingers = []

    # thumb
    fingers.append(hand[4].x > hand[1].x)


    return fingers


model_path = "/home/lostfromlight/Programming/Frameworks/Mediapipe/GestureControl/hand_landmarker.task"

base_options = python.BaseOptions(model_asset_path=model_path)

options = vision.HandLandmarkerOptions(
    base_options=base_options,
    num_hands=2
)

hand_landmarker = vision.HandLandmarker.create_from_options(options)

cap = cv2.VideoCapture(0)

previous_gesture = None

while cap.isOpened():
    time.sleep(0.01)
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)

    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    mp_image = mp.Image(
        image_format=mp.ImageFormat.SRGB,
        data=rgb_frame
    )

    detection_result = hand_landmarker.detect(mp_image)

    if detection_result.hand_landmarks:

        h, w, _ = frame.shape

        for hand_landmarks in detection_result.hand_landmarks:

            fingers = get_fingers_up(hand_landmarks)

            gesture = None

            if fingers == [True]:
                gesture = "THUMBS_UP"
            else:
                gesture = "THUMBS_DOWN"

            if gesture == "THUMBS_UP" and previous_gesture != "THUMBS_UP":
                print("👍 Thumbs up detected!")
                subprocess.run(["/home/lostfromlight/.dotfiles/home/scripts/lightmode.sh"])
            elif gesture == "THUMBS_DOWN" and previous_gesture != "THUMBS_DOWN":
                subprocess.run(["/home/lostfromlight/.dotfiles/home/scripts/darkmode.sh"])


            previous_gesture = gesture

            for landmark in hand_landmarks:
                x = int(landmark.x * w)
                y = int(landmark.y * h)

                cv2.circle(frame, (x, y), 5, (0,255,0), -1)

    #cv2.imshow("Feed", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break


cap.release()
cv2.destroyAllWindows()
