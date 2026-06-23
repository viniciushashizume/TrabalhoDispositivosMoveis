import sys
import os
import pandas as pd

# Adiciona a pasta api ao path para conseguir importar o app
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(BASE_DIR)

from fastapi.testclient import TestClient
from main import app, load_model

# Carrega os modelos simulando o startup
load_model()

client = TestClient(app)

print("\n[TESTE] Executando análise preditiva conjunta via API (/predict):")
print("=" * 70)

test_cases = [
    {
        "name": "Ana Souza (Exaustão e marcadores de risco textuais)",
        "payload": {
            "text": "hoje eu me sinto com exaustao extrema e muito burnout. não consigo focar."
        }
    },
    {
        "name": "Bruno Lima (Totalmente Saudável, com check-in)",
        "payload": {
            "text": "hoje eu acordei muito feliz, dormi bem e me sinto motivado e produtivo.",
            "humor": 5,
            "horasSono": 8,
            "nivelEstresse": 1,
            "atividadeFisica": 5,
            "interacaoSocial": 4
        }
    },
    {
        "name": "Carla Mendes (Risco Misto - Check-in ruim, texto alerta)",
        "payload": {
            "text": "sinto que o dia foi péssimo. estou com insonia e isolamento.",
            "humor": 1,
            "horasSono": 3,
            "nivelEstresse": 5,
            "atividadeFisica": 1,
            "interacaoSocial": 1
        }
    },
    {
        "name": "Daniel Rocha (Emergência Clínica - Salvaguarda atuando)",
        "payload": {
            "text": "a dor está insuportável. sinto desesperanca profunda e quero morrer.",
            "humor": 2,
            "horasSono": 4,
            "nivelEstresse": 5,
            "atividadeFisica": 1,
            "interacaoSocial": 1
        }
    }
]

for case in test_cases:
    response = client.post("/predict", json=case["payload"])
    
    print(f"Paciente: {case['name']}")
    print(f"Payload Enviado: {case['payload']}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"Marcadores Identificados: {data.get('marcadores_identificados', [])}")
        print(f"Classificação: {data.get('risco_predito')} (Probabilidade Alto Risco: {data.get('probabilidade_alto_risco', 0)*100:.1f}%)")
    else:
        print(f"Erro na API: {response.status_code} - {response.text}")
        
    print("-" * 70)