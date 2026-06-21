from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import joblib
import pandas as pd
import os
import re
import unicodedata
from core.database import supabase

app = FastAPI(title="Saúde Mental - API NLP e Extração de Marcadores")

# Modelo de entrada simplificado para focar no diário/texto
class TextPredictionInput(BaseModel):
    text: str

class PredictionResponse(BaseModel):
    risco_predito: str
    confianca: float
    probabilidade_alto_risco: float
    marcadores_identificados: List[str] 

class MockDataConfig(BaseModel):
    quantidade: int = 15
    user_id: str = "00000000-0000-0000-0000-000000000001"

# Caminho atualizado para o novo pipeline focado em PLN
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PIPELINE_PATH = os.path.join(BASE_DIR, 'models', 'nlp_pipeline.pkl')
pipeline = None

# O dicionário de ALERT_KEYWORDS existente é excelente. Mantenha ele como está no seu código original.
ALERT_KEYWORDS = {
    "exausto": "Exaustão", "exaustao": "Exaustão", "burnout": "Risco de Burnout",
    "ansiedade": "Ansiedade", "panico": "Crise de Pânico", "palpitacao": "Sintoma Físico (Palpitação)",
    "triste": "Tristeza", "desespero": "Desespero", "depressao": "Depressão",
    "morrer": "Ideação de Risco", "suicidio": "Risco Crítico", "sumir": "Ideação de Fuga"
    # ... (manter todos os seus mapeamentos)
}

def clean_text(text: str) -> str:
    text = str(text).lower()
    text = "".join(c for c in unicodedata.normalize('NFD', text) if unicodedata.category(c) != 'Mn')
    text = re.sub(r'[^\w\s]', '', text)
    return text

def extract_risk_keywords(text: str) -> List[str]:
    cleaned = clean_text(text)
    detected = []
    for kw, clinical_label in ALERT_KEYWORDS.items():
        pattern = r'\b' + re.escape(clean_text(kw)) + r'\b'
        if re.search(pattern, cleaned) or (kw in cleaned and len(kw) > 4):
            if clinical_label not in detected:
                detected.append(clinical_label)
    return detected

@app.on_event("startup")
@app.on_event("startup")
def load_model():
    global pipeline
    # ADICIONE ESTA LINHA DE DEBUG:
    print(f"[DEBUG] O FastAPI está a procurar o modelo exatamente em:\n{os.path.abspath(PIPELINE_PATH)}")

    if os.path.exists(PIPELINE_PATH):
        try:
            pipeline = joblib.load(PIPELINE_PATH)
            print("[PLN] Pipeline carregado com sucesso!")
        except Exception as e:
            print(f"[PLN] Erro ao carregar o pipeline: {e}")
    else:
        print("[PLN] Atenção: Modelo não encontrado. Rode 'python train_model.py'.")

@app.post("/inject-mocks")
def inject_mocks(config: MockDataConfig):
    amostras_mockadas = [
        ("Hoje tive um dia tranquilo e consegui descansar bem.", "baixo", 0, ["bem-estar", "descanso"]),
        ("Acordei com muita ansiedade e não consegui me concentrar.", "alto", 2, ["ansiedade", "dificuldade de concentração"]),
        ("Passei um tempo feliz com minha família e me senti acolhido.", "baixo", 0, ["felicidade", "apoio social"]),
        ("Estou sentindo uma exaustão constante, mesmo depois de dormir.", "alto", 2, ["exaustão", "sono não reparador"]),
        ("Consegui cumprir minhas tarefas e terminei o dia em paz.", "baixo", 0, ["tranquilidade", "produtividade"]),
        ("O trabalho está me consumindo e sinto que estou entrando em burnout.", "alto", 3, ["burnout", "estresse ocupacional"]),
        ("Fiz uma caminhada, respirei ar fresco e fiquei mais animado.", "baixo", 0, ["atividade física", "ânimo"]),
        ("Tive uma crise de pânico e fiquei com medo de acontecer novamente.", "alto", 3, ["pânico", "medo"]),
        ("Dormi bem e acordei disposto para começar o dia.", "baixo", 0, ["sono adequado", "disposição"]),
        ("Minha ansiedade ficou muito forte e senti o coração acelerar.", "alto", 2, ["ansiedade", "palpitação"]),
        ("Conversei com amigos e me diverti bastante durante a tarde.", "baixo", 0, ["socialização", "felicidade"]),
        ("Estou enfrentando uma tristeza profunda e não quero fazer nada.", "alto", 3, ["tristeza", "desmotivação"]),
        ("Hoje fiquei um pouco cansado, mas consegui relaxar depois.", "baixo", 1, ["cansaço leve", "recuperação"]),
        ("Tenho me sentido preso em uma depressão que parece não passar.", "alto", 3, ["depressão", "desesperança"]),
        ("O dia foi corrido, porém consegui organizar tudo sem me desesperar.", "baixo", 1, ["estresse leve", "autorregulação"]),
        ("A exaustão mental está afetando meu trabalho e relacionamentos.", "alto", 3, ["exaustão", "prejuízo funcional"]),
        ("Estou contente porque consegui resolver um problema importante.", "baixo", 0, ["satisfação", "realização"]),
        ("Sinto sinais de burnout, estou irritado, cansado e sem motivação.", "alto", 3, ["burnout", "irritabilidade", "desmotivação"]),
        ("Tive preocupação com uma prova, mas consegui estudar e me acalmar.", "baixo", 1, ["preocupação leve", "autorregulação"]),
        ("Passei o dia com tristeza e uma sensação forte de vazio.", "alto", 2, ["tristeza", "vazio"]),
        ("Preparei uma refeição, cuidei de mim e tive uma noite agradável.", "baixo", 0, ["autocuidado", "bem-estar"]),
        ("A ansiedade não me deixou dormir e tive pensamentos acelerados.", "alto", 2, ["ansiedade", "insônia", "ruminação"]),
        ("Mesmo com pequenos problemas, consegui manter a calma hoje.", "baixo", 1, ["resiliência", "tranquilidade"]),
        ("Senti pânico ao sair de casa e precisei voltar imediatamente.", "alto", 3, ["pânico", "evitação"]),
        ("Recebi uma boa notícia e passei o restante do dia feliz.", "baixo", 0, ["felicidade", "otimismo"]),
        ("Estou tão exausto que não consigo terminar tarefas simples.", "alto", 3, ["exaustão", "prejuízo funcional"]),
        ("Senti saudade e fiquei triste por um momento, depois melhorei.", "baixo", 1, ["tristeza passageira", "recuperação"]),
        ("A depressão tem tirado minha energia e meu interesse pelas coisas.", "alto", 3, ["depressão", "anedonia", "baixa energia"]),
        ("Consegui descansar, ouvir música e terminar o dia mais leve.", "baixo", 0, ["relaxamento", "bem-estar"]),
        ("Minha ansiedade virou desespero e não consigo pensar com clareza.", "alto", 3, ["ansiedade", "desespero", "confusão"]),
    ]

    split_por_par = [
        "train", "train", "validation", "train", "test",
        "train", "train", "validation", "train", "test",
        "train", "train", "train", "train", "test",
    ]

    dados = []
    for indice in range(config.quantidade):
        indice_amostra = indice % len(amostras_mockadas)
        texto, risco, intensidade, categorias = amostras_mockadas[indice_amostra]

        dataset_split = split_por_par[indice_amostra // 2]

        dados.append({
            "user_id": config.user_id,
            "content": texto,
            "date": datetime.now().isoformat(),
            "expected_risk": risco,
            "expected_risk_binary": 1 if risco == "alto" else 0,
            "expected_risk_score": intensidade,
            "expected_categories": categorias,
            "is_synthetic": True,
            "dataset_split": dataset_split,
            "label_source": "mock_hardcoded_v1",
            "label_reviewed": False,
            "language": "pt-BR",
            "mock_group_id": f"mock_{indice_amostra + 1:03d}",
        })

    try:
        resposta = supabase.table("diaries").insert(dados).execute()
    except Exception as erro:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao inserir dados mockados no Supabase: {erro}",
        ) from erro

    return {
        "sucesso": True,
        "quantidade_inserida": len(dados),
        "dados": resposta.data,
    }

@app.post("/predict", response_model=PredictionResponse)
def predict_risk(data: TextPredictionInput):
    if pipeline is None:
        raise HTTPException(status_code=500, detail="Modelo NLP não está carregado.")
    
    try:
        # A predição agora recebe apenas um array ou Series contendo o texto
        prediction = pipeline.predict([data.text])[0]
        probabilities = pipeline.predict_proba([data.text])[0]
        
        is_high_risk = bool(prediction == 1)
        prob_high_risk = float(probabilities[1])
        prob_low_risk = float(probabilities[0])
        
        # O sistema de extração de marcadores continua sendo nossa salvaguarda clínica principal
        marcadores_detectados = extract_risk_keywords(data.text)
        
        critical_indicators = ["Risco Crítico", "Ideação de Risco", "Ideação de Desistência", "Ideação de Fuga"]
        has_critical = any(ind in marcadores_detectados for ind in critical_indicators)
        
        if has_critical:
            is_high_risk = True
            prob_high_risk = max(prob_high_risk, 0.95)
            prob_low_risk = min(prob_low_risk, 0.05)
            
        classe_risco = "Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco"
        
        return PredictionResponse(
            risco_predito=classe_risco,
            confianca=max(prob_high_risk, prob_low_risk),
            probabilidade_alto_risco=prob_high_risk,
            marcadores_identificados=marcadores_detectados
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro durante a análise NLP: {str(e)}")
