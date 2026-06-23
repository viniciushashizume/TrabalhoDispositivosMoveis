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

# Modelo de entrada com dados textuais e quantitativos opcionais
class PredictionInput(BaseModel):
    text: str
    humor: Optional[int] = None
    horasSono: Optional[int] = None
    nivelEstresse: Optional[int] = None
    atividadeFisica: Optional[int] = None
    interacaoSocial: Optional[int] = None
    user_email: Optional[str] = None
    id_registro: Optional[str] = None
    tipo: Optional[str] = "diario"

class PredictionResponse(BaseModel):
    risco_predito: str
    confianca: float
    probabilidade_alto_risco: float
    marcadores_identificados: List[str] 

class MockDataConfig(BaseModel):
    quantidade: int = 15
    user_id: str = "00000000-0000-0000-0000-000000000001"

# Caminho atualizado para os pipelines NLP e Preditivo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
NLP_PIPELINE_PATH = os.path.join(BASE_DIR, 'models', 'nlp_pipeline.pkl')
PREDICTIVE_PIPELINE_PATH = os.path.join(BASE_DIR, 'models', 'predictive_pipeline.pkl')
nlp_pipeline = None
predictive_pipeline = None

# Marcadores clínicos de risco
ALERT_KEYWORDS = {
    "suicidio": "Risco Crítico", "morrer": "Ideação de Risco", "matar": "Ideação de Risco",
    "sumir": "Ideação de Fuga", "desaparecer": "Ideação de Fuga",
    "automutilacao": "Automutilação", "cortar": "Automutilação",
    "desesperanca": "Desesperança", "vazio": "Sentimento de Vazio", "inutil": "Sentimento de Inutilidade",
    "culpa": "Culpa Excessiva", "fardo": "Sentimento de Fardo",
    "panico": "Crise de Pânico", "ataque de panico": "Crise de Pânico",
    "insonia": "Insônia Severa", "nao durmo": "Privação de Sono",
    "delirio": "Sintoma Psicótico", "alucinacao": "Sintoma Psicótico",
    "vozes": "Sintoma Psicótico (Vozes)",
    "isolamento": "Isolamento Social", "nao saio": "Isolamento Social",
    "anedonia": "Anedonia", "perdi a vontade": "Anedonia", "sem prazer": "Anedonia",
    "burnout": "Risco de Burnout", "exaustao extrema": "Exaustão Severa",
    "ansiedade": "Sintoma de Ansiedade", "angustia": "Angústia",
    "desespero": "Desespero", "triste": "Humor Deprimido", "tristeza": "Humor Deprimido",
    "ruim": "Afeto Negativo", "pessimo": "Afeto Negativo",
    "cansado": "Cansaço Excessivo", "exaustao": "Exaustão",
    "medo": "Sintoma de Ansiedade (Medo)"
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
def load_model():
    global nlp_pipeline, predictive_pipeline

    if os.path.exists(NLP_PIPELINE_PATH):
        try:
            nlp_pipeline = joblib.load(NLP_PIPELINE_PATH)
            print("[PLN] Pipeline NLP carregado com sucesso!")
        except Exception as e:
            print(f"[PLN] Erro ao carregar o pipeline NLP: {e}")
            
    if os.path.exists(PREDICTIVE_PIPELINE_PATH):
        try:
            predictive_pipeline = joblib.load(PREDICTIVE_PIPELINE_PATH)
            print("[ML] Predictive Pipeline (Check-in) carregado com sucesso!")
        except Exception as e:
            print(f"[ML] Erro ao carregar o Predictive Pipeline: {e}")

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
def predict_risk(data: PredictionInput):
    if nlp_pipeline is None:
        raise HTTPException(status_code=500, detail="Modelo NLP não está carregado.")
    
    try:
        # 1. Análise Qualitativa (PLN)
        nlp_pred = nlp_pipeline.predict([data.text])[0]
        nlp_probs = nlp_pipeline.predict_proba([data.text])[0]
        prob_high_risk_nlp = float(nlp_probs[1])
        
        # 2. Análise Quantitativa (Check-in via Predictive Pipeline)
        prob_high_risk_quant = None
        has_quant_data = all(v is not None for v in [data.humor, data.horasSono, data.nivelEstresse, data.atividadeFisica, data.interacaoSocial])
        
        if has_quant_data and predictive_pipeline is not None:
            quant_df = pd.DataFrame([{
                'humor': data.humor,
                'horasSono': data.horasSono,
                'nivelEstresse': data.nivelEstresse,
                'atividadeFisica': data.atividadeFisica,
                'interacaoSocial': data.interacaoSocial
            }])
            quant_probs = predictive_pipeline.predict_proba(quant_df)[0]
            prob_high_risk_quant = float(quant_probs[1])
        
        # 3. Avaliação Conjunta e Direcionamento por Tipo
        if data.tipo == "checkin" and prob_high_risk_quant is not None:
            # Se for checkin, ignora o texto padrão enviado e confia 100% nos números
            prob_high_risk = prob_high_risk_quant
        elif prob_high_risk_quant is not None:
            # Se não for só checkin mas tiver os dados quantitativos, faz a ponderação
            prob_high_risk = (prob_high_risk_nlp * 0.6) + (prob_high_risk_quant * 0.4)
        else:
            prob_high_risk = prob_high_risk_nlp
            
        prob_low_risk = 1.0 - prob_high_risk
        is_high_risk = prob_high_risk > 0.5
        
        # 4. Extração de Marcadores Clínicos (Salvaguarda - apenas para diários reais)
        if data.tipo == "checkin":
            marcadores_detectados = []
            has_critical = False
        else:
            marcadores_detectados = extract_risk_keywords(data.text)
            critical_indicators = ["Risco Crítico", "Ideação de Risco", "Automutilação", "Ideação de Fuga", "Desesperança"]
            has_critical = any(ind in marcadores_detectados for ind in critical_indicators)
        
        if has_critical:
            is_high_risk = True
            prob_high_risk = max(prob_high_risk, 0.95)
            prob_low_risk = min(prob_low_risk, 0.05)
            
        classe_risco = "Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco"
        
        if data.user_email and data.id_registro:
            base_destino = "relatorios_txt"
            safe_email = "".join(c for c in data.user_email if c.isalnum() or c in "@.-_")
            pasta_usuario = os.path.join(base_destino, safe_email, f"{data.tipo}s")
            os.makedirs(pasta_usuario, exist_ok=True)
            caminho_arquivo = os.path.join(pasta_usuario, f"analise_{data.id_registro}.txt")
            
            with open(caminho_arquivo, "w", encoding="utf-8") as file:
                file.write(f"Usuário / Email: {data.user_email}\n")
                file.write(f"ID {data.tipo.capitalize()}: {data.id_registro}\n")
                file.write("-" * 45 + "\n")
                if data.tipo == "checkin" and has_quant_data:
                    file.write("Análise via ML - random forest\n")
                    file.write(f"Classificação: {classe_risco}\n")
                    file.write("Parâmetros Analisados:\n")
                    file.write(f"> humor: {data.humor}\n")
                    file.write(f"> horasSono: {data.horasSono}\n")
                    file.write(f"> nivelEstresse: {data.nivelEstresse}\n")
                    file.write(f"> atividadeFisica: {data.atividadeFisica}\n")
                    file.write(f"> interacaoSocial: {data.interacaoSocial}\n")
                else:
                    file.write("Análise via NLP\n")
                    file.write(f"Texto Analisado: \"{data.text}\"\n")
                    file.write(f"Classificação PLN: {classe_risco}\n")
                    marcadores_str = ', '.join(marcadores_detectados) if marcadores_detectados else 'Nenhum'
                    file.write(f"Marcadores Identificados: {marcadores_str}\n")
                file.write("-" * 45 + "\n")
        
        return PredictionResponse(
            risco_predito=classe_risco,
            confianca=max(prob_high_risk, prob_low_risk),
            probabilidade_alto_risco=prob_high_risk,
            marcadores_identificados=marcadores_detectados
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro durante a análise preditiva: {str(e)}")
