import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import Pipeline
import joblib
import os

# Função original mantida para gerar mock data, mas focaremos apenas no texto
def generate_mock_data(n_samples=1000):
    np.random.seed(42)
    
    text_samples_good = [
        "Me sinto ótimo hoje, produtivo e focado nas minhas tarefas.",
        "Excelente noite de sono, acordei com bastante disposição e energia.",
        "O dia foi muito tranquilo e pacífico, sem qualquer sinal de estresse.",
        "Focado e motivado com o novo projeto. O ambiente de trabalho está ótimo.",
        "Tudo bem por aqui, sem reclamações. Fui dar uma caminhada e relaxei.",
        # ... (adicione o restante dos seus textos positivos aqui)
    ]
    
    text_samples_bad = [
        "Estou me sentindo muito exausta com a quantidade de tarefas acumuladas hoje.",
        "Trabalho sob pressão constante, sinto que não vou dar conta desse ritmo de cobranças.",
        "Mais um dia super cansativo. Fiquei até tarde e já acordei sem ânimo e esgotada.",
        "A dor psicológica está insuportável hoje. Às vezes penso que seria melhor morrer ou sumir de vez.",
        "Coração disparado e falta de ar constante. A ansiedade está me sufocando hoje e me paralisa.",
        # ... (adicione o restante dos seus textos negativos aqui)
    ]
    
    data = []
    labels = [] 
    
    for _ in range(n_samples):
        risk = np.random.choice([0, 1])
        labels.append(risk)
        
        if risk == 0:
            text = np.random.choice(text_samples_good)
        else:
            text = np.random.choice(text_samples_bad)
            
        # Coletamos apenas o texto, ignorando os inputs numéricos de check-in
        data.append({'text': text})
        
    df = pd.DataFrame(data)
    y = np.array(labels)
    return df, y

def train_and_save_nlp_model():
    print("[PLN] Gerando dados de treinamento simulados focados em texto...")
    X, y = generate_mock_data(1200)
    
    # Separando treino e teste (passamos apenas a série de texto)
    X_train, X_test, y_train, y_test = train_test_split(X['text'], y, test_size=0.2, random_state=42)
    
    print("[PLN] Criando o pipeline de Processamento de Linguagem Natural...")
    
    # Pipeline focado puramente em extração de features do texto (N-grams ajudam a pegar contexto)
    pipeline = Pipeline(steps=[
        ('tfidf', TfidfVectorizer(max_features=1000, stop_words=None, ngram_range=(1, 3))),
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
    
    print("[PLN] Treinando o modelo preditivo baseado em texto...")
    pipeline.fit(X_train, y_train)
    
    score = pipeline.score(X_test, y_test)
    print(f"[PLN] Acurácia no teste do modelo NLP: {score * 100:.2f}%")
    
    print("[PLN] Salvando o modelo treinado...")

    # Lê a pasta atual (services) e recua um nível para a raiz (api)
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    MODELS_DIR = os.path.join(BASE_DIR, 'models')

    os.makedirs(MODELS_DIR, exist_ok=True)

    # Define o caminho absoluto final do ficheiro
    pipeline_path = os.path.join(MODELS_DIR, 'nlp_pipeline.pkl')

    joblib.dump(pipeline, pipeline_path)
    print(f"[PLN] Pipeline salvo com sucesso em: {pipeline_path}")

if __name__ == '__main__':
    train_and_save_nlp_model()