import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neural_network import MLPClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import KFold, cross_val_score
import joblib
import re
import os

model_path = 'final_data/final_model_v2.h5'
model_pic_path = 'final_data/picke.pkl'

# Step 1: Load the data from the JSON file
with open('final_data/combined_medical_data_lower.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Step 2: Preprocess the data
keys = list(data.keys())
definitions = [data[key]['Definition'] for key in keys]

# Step 3: Vectorize the input keys
vectorizer = TfidfVectorizer()
X = vectorizer.fit_transform(keys)

# Step 4: Encode the output definitions
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(definitions)

# if os.path.exists(model_path):
if False:
    # Load the trained model
    model = joblib.load(model_path)
    print("Model loaded successfully.")
else:
    # Step 5: Build the neural network model
    model = MLPClassifier(hidden_layer_sizes=(100,), max_iter=1000)

    # Step 6: Perform k-fold cross-validation
    kfold = KFold(n_splits=5, shuffle=True, random_state=42)
    scores = cross_val_score(model, X, y, cv=kfold)

    print("Cross-Validation Accuracy Scores:")
    for i, score in enumerate(scores):
        print(f"Fold {i + 1}: {score}")

    # Step 7: Train the model on the entire dataset
    model.fit(X, y)
    print("Model trained successfully.")

    # Save the trained model
    joblib.dump(model, model_path)
    joblib.dump(model, model_pic_path)

    print("Model saved successfully.")

# Step 8: Define method to get definition from the model
def get_definition_from_model(word):
    word_vector = vectorizer.transform([word])
    label = model.predict(word_vector)[0]
    definition = label_encoder.inverse_transform([label])[0]
    return definition

# Step 9: Prompt user for input
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
        prediction = model.predict(vectorizer.transform([phrase]))[0]
        confidence = model.predict_proba(vectorizer.transform([phrase]))[0][prediction]

        if confidence > 0.85 and phrase.lower() in keys:
            definition = get_definition_from_model(phrase)
            print(f"{phrase}: {definition} (Confidence: {confidence})")
