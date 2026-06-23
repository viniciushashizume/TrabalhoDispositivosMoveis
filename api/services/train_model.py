import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neural_network import MLPClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
import joblib
import os
import random

RISK_MARKERS = [
    "suicidio", "morrer", "matar", "sumir", "desaparecer", "automutilacao", "cortar",
    "desesperanca", "vazio", "inutil", "culpa", "fardo", "panico", "ataque de panico",
    "insonia", "nao durmo", "delirio", "alucinacao", "vozes", "isolamento", "nao saio",
    "anedonia", "perdi a vontade", "sem prazer", "burnout", "exaustao extrema",
    "ansiedade", "angustia", "desespero", "triste", "tristeza", "ruim", "pessimo",
    "cansado", "exaustao", "medo"
]

POSITIVE_MARKERS = [
    "bem-estar", "feliz", "alegre", "motivado", "energia", "disposicao", "esperanca",
    "otimista", "descansado", "dormi bem", "calmo", "tranquilo", "exercicio",
    "caminhada", "treino", "amigos", "familia", "conversei", "produtivo", "focado"
]

NEUTRAL_FILLERS = [
    "hoje eu", "sinto que", "estou", "no trabalho", "em casa", "durante a tarde", 
    "quando acordei", "agora", "fiquei"
]

def generate_synthetic_data(n_samples=2000):
    np.random.seed(42)
    random.seed(42)
    
    data = []
    
    for _ in range(n_samples):
        risk_label = np.random.choice([0, 1])
        
        num_markers = random.randint(1, 3)
        if risk_label == 1:
            chosen_markers = random.sample(RISK_MARKERS, num_markers)
            humor = np.random.randint(1, 5) # 1 a 4
            horas_sono = np.random.choice([np.random.randint(0, 5), np.random.randint(11, 15)]) # muito pouco ou muito
            nivel_estresse = np.random.randint(4, 6) # 4 ou 5
            atividade_fisica = 0 # Falso
            interacao_social = 0 # Isolado
        else:
            chosen_markers = random.sample(POSITIVE_MARKERS, num_markers)
            humor = np.random.randint(5, 11) # 5 a 10
            horas_sono = np.random.randint(6, 10) # 6 a 9
            nivel_estresse = np.random.randint(1, 4) # 1 a 3
            atividade_fisica = 1 # Verdadeiro
            interacao_social = np.random.randint(1, 3) # 1 (Pouco) ou 2 (Muito)
        
        text_parts = []
        for marker in chosen_markers:
            filler = random.choice(NEUTRAL_FILLERS)
            text_parts.append(f"{filler} {marker}")
            
        text = ", ".join(text_parts) + "."
        
        data.append({
            'text': text,
            'humor': humor,
            'horasSono': horas_sono,
            'nivelEstresse': nivel_estresse,
            'atividadeFisica': atividade_fisica,
            'interacaoSocial': interacao_social,
            'risk_label': risk_label
        })
        
    return pd.DataFrame(data)

def train_and_save_models():
    print("[ML] Gerando dados de treinamento sintéticos com marcadores clínicos reais...")
    df = generate_synthetic_data(2500)
    
    print("[PLN] Treinando o modelo de Processamento de Linguagem Natural...")
    X_text = df['text']
    y = df['risk_label']
    
    X_train_t, X_test_t, y_train_t, y_test_t = train_test_split(X_text, y, test_size=0.2, random_state=42)
    
    nlp_pipeline = Pipeline(steps=[
        ('tfidf', TfidfVectorizer(max_features=1500, ngram_range=(1, 3))),
        ('classifier', MLPClassifier(
            hidden_layer_sizes=(64, 32),
            activation='relu',
            solver='adam',
            max_iter=500,
            random_state=42,
            early_stopping=True,
            validation_fraction=0.1
        ))
    ])
    nlp_pipeline.fit(X_train_t, y_train_t)
    print(f"curácia NLP (Texto): {nlp_pipeline.score(X_test_t, y_test_t) * 100:.2f}%")
    
    print("Treinando o Predictive Pipeline (Métricas Quantitativas - Random Forest)...")
    FEATURES = ['humor', 'horasSono', 'nivelEstresse', 'atividadeFisica', 'interacaoSocial']
    X_quant = df[FEATURES]
    
    X_train_q, X_test_q, y_train_q, y_test_q = train_test_split(X_quant, y, test_size=0.2, random_state=42)
    
    rf_pipeline = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, class_weight='balanced')
    rf_pipeline.fit(X_train_q, y_train_q)
    print(f"[ML] Acurácia Predictive Pipeline (Quantitativo): {rf_pipeline.score(X_test_q, y_test_q) * 100:.2f}%")
    
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    MODELS_DIR = os.path.join(BASE_DIR, 'models')
    os.makedirs(MODELS_DIR, exist_ok=True)
    
    nlp_path = os.path.join(MODELS_DIR, 'nlp_pipeline.pkl')
    predictive_path = os.path.join(MODELS_DIR, 'predictive_pipeline.pkl')
    
    joblib.dump(nlp_pipeline, nlp_path)
    joblib.dump(rf_pipeline, predictive_path)
    print(f"[ML] Modelos salvos com sucesso em {MODELS_DIR}!")

if __name__ == '__main__':
    train_and_save_models()