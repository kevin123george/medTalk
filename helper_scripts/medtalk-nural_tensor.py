import json
import numpy as np
import tensorflow as tf
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import KFold, cross_val_score
import joblib
import re
import os

model_path = 'final_data/final_model_tf_v3.h5'

# Step 1: Load the data from the JSON file
with open('final_data/combined_medical_data_lower.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Step 2: Preprocess the data
keys = list(data.keys())
definitions = [data[key]['Definition'] for key in keys]

# Step 3: Vectorize the input keys
vectorizer = TfidfVectorizer()
X = vectorizer.fit_transform(keys).toarray()

# Step 4: Encode the output definitions
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(definitions)

# Step 5: Check if the model file exists
# if False
if os.path.exists(model_path):
    # Load the trained model
    model = tf.keras.models.load_model(model_path)
    print("Model loaded successfully.")
else:
    # Step 6: Build the neural network model
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(100, activation='relu'),
        tf.keras.layers.Dense(len(label_encoder.classes_), activation='softmax')
    ])

    # Step 7: Compile the model
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

    # Step 8: Train the model
    history = model.fit(X, y, epochs=1000, batch_size=64)

    # Save the trained model
    model.save(model_path)
    print("Model saved successfully.")


# Step 9: Define method to get definition from the model
def get_definition_from_model(word):
    word_vector = vectorizer.transform([word]).toarray()
    label_probs = model.predict(word_vector)[0]
    label = np.argmax(label_probs)
    definition = label_encoder.inverse_transform([label])[0]
    confidence = label_probs[label]
    return definition, confidence


# Step 10: Prompt user for input
while True:
    user_input = input("Enter a sentence (or 'q' to quit): ")
    if user_input.lower() == 'q':
        break

    print("--------------")
    preprocessed_words = re.findall(r'\b\w+\b', user_input.lower())
    combinations = []
    for i in range(len(preprocessed_words)):
        for j in range(i + 1, len(preprocessed_words) + 1):
            phrase = ' '.join(preprocessed_words[i:j])
            combinations.append(phrase)

    for phrase in combinations:
        word_vector = vectorizer.transform([phrase]).toarray()
        prediction, confidence = get_definition_from_model(phrase)

        if confidence > 0.85 and phrase.lower() in keys:
            print(f"{phrase}: {prediction} (Confidence: {confidence})")

print("convert model to tflite ")

# Load the saved TensorFlow model
model = tf.keras.models.load_model(model_path)

# Convert the TensorFlow model to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TensorFlow Lite model to a .tflite file
with open('model_tf_v3.tflite', 'wb') as file:
    file.write(tflite_model)


import matplotlib.pyplot as plt

# Step 8: Train the model
# history = model.fit(X, y, epochs=1000, batch_size=64)

# Plot accuracy
plt.plot(history.history['accuracy'])
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.show()

# Plot loss
plt.plot(history.history['loss'])
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.show()
