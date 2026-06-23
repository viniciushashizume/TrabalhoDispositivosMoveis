import os
import sys
import pandas as pd
import joblib

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.database import supabase
from services.ml_pipeline import gerar_relatorios_checkin, gerar_relatorios_diario, FEATURES
from main import extract_risk_keywords

def get_user_email(user_id: str) -> str:
    try:
        user_response = supabase.auth.admin.get_user_by_id(user_id)
        return user_response.user.email
    except Exception as e:
        print(f"[AVISO] Não foi possível obter o email para {user_id}: {e}")
        return f"usuario_{user_id[:8]}"

def gerar_relatorios_do_banco():
    print("[SUPABASE] Conectando ao banco de dados e buscando registros...")
    
    resposta_checkins = supabase.table("checkins").select("*").execute()
    dados_checkins = resposta_checkins.data
    df_pacientes = pd.DataFrame(dados_checkins) if dados_checkins else pd.DataFrame()
    
    if not df_pacientes.empty:
        if 'interacaoSocial' in df_pacientes.columns:
            def map_interacao(val):
                s = str(val).lower()
                if "isolado" in s: return 0
                if "muito" in s: return 2
                return 1
            df_pacientes['interacaoSocial'] = df_pacientes['interacaoSocial'].apply(map_interacao)
            
        if 'atividadeFisica' in df_pacientes.columns:
            df_pacientes['atividadeFisica'] = df_pacientes['atividadeFisica'].fillna(False).astype(int)

        for col in FEATURES:
            if col not in df_pacientes.columns:
                df_pacientes[col] = 3
            df_pacientes[col] = pd.to_numeric(df_pacientes[col], errors='coerce').fillna(3)
        
    resposta_diarios = supabase.table("diaries").select("*").execute()
    dados_diarios = resposta_diarios.data
    df_diarios = pd.DataFrame(dados_diarios) if dados_diarios else pd.DataFrame()

    caminho_modelo_nlp = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'models', 'nlp_pipeline.pkl')
    caminho_modelo_rf = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'models', 'predictive_pipeline.pkl')
    
    pipeline_nlp = None
    pipeline_rf = None
    
    try:
        pipeline_nlp = joblib.load(caminho_modelo_nlp)
        print("[PLN] Modelo NLP carregado com sucesso.")
    except Exception as e:
        print(f"[ERRO] Não foi possível carregar o modelo NLP: {e}")
        
    try:
        pipeline_rf = joblib.load(caminho_modelo_rf)
        print("[ML] Modelo RF carregado com sucesso.")
    except Exception as e:
        print(f"[ERRO] Não foi possível carregar o modelo RF: {e}")

    email_cache = {}

    arquivos_gerados_checkins = []
    if not df_pacientes.empty:
        previsoes_rf = []
        emails_checkin = []
        if pipeline_rf is not None:
            X_quant = df_pacientes[FEATURES]
            preds = pipeline_rf.predict_proba(X_quant)
            for p in preds:
                is_high_risk = bool(p[1] > 0.5)
                previsoes_rf.append("Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco")
        else:
            previsoes_rf = ["Risco Desconhecido"] * len(df_pacientes)
            
        for index, row in df_pacientes.iterrows():
            id_usuario = row.get('user_id')
            if id_usuario not in email_cache:
                email_cache[id_usuario] = get_user_email(id_usuario)
            emails_checkin.append(email_cache[id_usuario])
            
        print("[GERAÇÃO] Criando relatórios de Check-in...")
        arquivos_gerados_checkins = gerar_relatorios_checkin(df_pacientes, previsoes_rf, emails_checkin)
        
    arquivos_gerados_diarios = []
    if not df_diarios.empty:
        resultados_nlp = []
        emails_diario = []
        
        for index, row in df_diarios.iterrows():
            id_usuario = row.get('user_id')
            if id_usuario not in email_cache:
                email_cache[id_usuario] = get_user_email(id_usuario)
            emails_diario.append(email_cache[id_usuario])
            
            texto_diario = str(row.get('content', ''))
            
            if texto_diario.strip() and pipeline_nlp is not None:
                prediction = pipeline_nlp.predict([texto_diario])[0]
                probabilities = pipeline_nlp.predict_proba([texto_diario])[0]
                is_high_risk = bool(prediction == 1)
                prob_high_risk = float(probabilities[1])
                
                marcadores = extract_risk_keywords(texto_diario)
                critical_indicators = ["Risco Crítico", "Ideação de Risco", "Automutilação", "Ideação de Fuga", "Desesperança"]
                has_critical = any(ind in marcadores for ind in critical_indicators)
                
                if has_critical:
                    is_high_risk = True
                    prob_high_risk = max(prob_high_risk, 0.95)
                    
                risco_texto = "Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco [OK]"
                confianca = max(prob_high_risk, 1 - prob_high_risk) * 100
            else:
                risco_texto = "Sem dados de texto"
                confianca = 0.0
                marcadores = extract_risk_keywords(texto_diario)

            resultados_nlp.append({
                'risco_texto': risco_texto,
                'confianca': confianca,
                'marcadores': marcadores
            })
            
        print("[GERAÇÃO] Criando relatórios de Diários...")
        arquivos_gerados_diarios = gerar_relatorios_diario(df_diarios, resultados_nlp, emails_diario)

    print(f"[SUCESSO] Foram gerados {len(arquivos_gerados_checkins)} relatórios de check-in e {len(arquivos_gerados_diarios)} relatórios de diários.")

if __name__ == "__main__":
    gerar_relatorios_do_banco()