import joblib
import pandas as pd
from main import extract_risk_keywords

print("[TESTE] Carregando o pipeline focado em PLN...")
pipeline = joblib.load("models/nlp_pipeline.pkl")

# Os casos de teste agora focam exclusivamente na capacidade de interpretação semântica do texto
test_cases = [
    {
        "name": "Ana Souza (Burnout)",
        "text": "Estou me sentindo muito exausta com a quantidade de tarefas acumuladas hoje. Cansaco extremo."
    },
    {
        "name": "Bruno Lima (Saudavel)",
        "text": "Me sinto otimo hoje, produtivo e focado nas minhas tarefas diarias."
    },
    {
        "name": "Carla Mendes (Ansiedade)",
        "text": "Sinto uma ansiedade enorme e palpitacao no peito constante, panico de errar na apresentacao."
    },
    {
        "name": "Daniel Rocha (Depressao/Alerta)",
        "text": "A dor psicologica esta insuportavel hoje. As vezes penso que seria melhor se eu morresse ou sumisse."
    }
]

print("\n[TESTE] Executando análise textual com PLN:")
print("=" * 60)

for case in test_cases:
    # Predição direta na string de texto
    prediction = pipeline.predict([case["text"]])[0]
    probabilities = pipeline.predict_proba([case["text"]])[0]
    
    is_high_risk = bool(prediction == 1)
    prob_high_risk = float(probabilities[1])
    
    # Extração de marcadores negativos
    marcadores = extract_risk_keywords(case["text"])
    
    critical_indicators = ["Risco Crítico", "Ideação de Risco", "Ideação de Desistência", "Ideação de Fuga"]
    has_critical = any(ind in marcadores for ind in critical_indicators)
    
    if has_critical:
        is_high_risk = True
        prob_high_risk = max(prob_high_risk, 0.95)
        
    risco_texto = "Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco [OK]"
    confianca = max(prob_high_risk, 1 - prob_high_risk)
    
    print(f"Paciente: {case['name']}")
    print(f"Texto Analisado: \"{case['text']}\"")
    print(f"Marcadores Identificados (Regras): {marcadores if marcadores else 'Nenhum'}")
    print(f"Classificação PLN: {risco_texto} (Confiança: {confianca * 100:.1f}%)")
    print("-" * 60)