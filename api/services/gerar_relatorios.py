import os
import sys
import pandas as pd
import joblib

# Adiciona a pasta raiz 'api' ao path para importar os módulos corretamente
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.database import supabase
from services.ml_pipeline import gerar_arquivos_txt, FEATURES
from main import extract_risk_keywords

def gerar_relatorios_do_banco():
    print("[SUPABASE] Conectando ao banco de dados e buscando registros...")
    
    # 1. Buscar Dados Quantitativos (Tabela de Check-ins)
    # IMPORTANTE: Verifique se o nome da tabela no Supabase é exatamente 'checkins'
    resposta_checkins = supabase.table("checkins").select("*").execute()
    dados_checkins = resposta_checkins.data
    
    if not dados_checkins:
        print("[AVISO] Nenhum check-in encontrado no Supabase.")
        return
        
    df_pacientes = pd.DataFrame(dados_checkins)
    
    # Preencher valores ausentes nas features com a mediana (boa prática para ML)
    for col in FEATURES:
        if col not in df_pacientes.columns:
            df_pacientes[col] = 3 # Valor neutro padrão caso a coluna falte
        df_pacientes[col] = pd.to_numeric(df_pacientes[col], errors='coerce').fillna(3)
        
    # 2. Buscar Dados Qualitativos (Tabela de Diários)
    # IMPORTANTE: Verifique se a tabela é 'diaries' e a coluna de texto é 'content' ou 'texto'
    resposta_diarios = supabase.table("diaries").select("*").execute()
    dados_diarios = resposta_diarios.data
    df_diarios = pd.DataFrame(dados_diarios)
    
    print(f"[SUPABASE] Encontrados {len(df_pacientes)} check-ins e {len(df_diarios)} diários.")

    # 3. Carregar o Modelo NLP
    caminho_modelo_nlp = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'models', 'nlp_pipeline.pkl')
    try:
        pipeline_nlp = joblib.load(caminho_modelo_nlp)
        print("[PLN] Modelo NLP carregado com sucesso.")
    except Exception as e:
        print(f"[ERRO] Não foi possível carregar o modelo NLP: {e}")
        return

    # Mock temporário do Random Forest (substitua pela carga do modelo .pkl real quando salvar o RF)
    previsoes_rf = ["Risco Moderado"] * len(df_pacientes) 

    textos_analisados = []
    resultados_nlp = []

    # 4. Processar cada check-in cruzando com os diários
    print("[PROCESSAMENTO] Analisando textos e gerando predições...")
    for index, row in df_pacientes.iterrows():
        id_usuario = row.get('user_id')
        
        # Tenta encontrar o diário correspondente a este usuário (exemplo: diário mais recente)
        # Ajuste a lógica de cruzamento de dados (join) conforme a estrutura das suas tabelas
        texto_diario = ""
        if not df_diarios.empty and 'user_id' in df_diarios.columns:
            diarios_usuario = df_diarios[df_diarios['user_id'] == id_usuario]
            if not diarios_usuario.empty:
                # Pega a coluna que contém o texto (ajuste 'content' para o nome da sua coluna)
                texto_diario = str(diarios_usuario.iloc[-1].get('content', ''))
        
        textos_analisados.append(texto_diario)
        
        # Processamento NLP para o diário encontrado
        if texto_diario.strip():
            prediction = pipeline_nlp.predict([texto_diario])[0]
            probabilities = pipeline_nlp.predict_proba([texto_diario])[0]
            is_high_risk = bool(prediction == 1)
            prob_high_risk = float(probabilities[1])
            
            marcadores = extract_risk_keywords(texto_diario)
            critical_indicators = ["Risco Crítico", "Ideação de Risco", "Ideação de Desistência", "Ideação de Fuga"]
            has_critical = any(ind in marcadores for ind in critical_indicators)
            
            if has_critical:
                is_high_risk = True
                prob_high_risk = max(prob_high_risk, 0.95)
                
            risco_texto = "Alto Risco [ALERTA]" if is_high_risk else "Baixo Risco [OK]"
            confianca = max(prob_high_risk, 1 - prob_high_risk) * 100
        else:
            risco_texto = "Sem dados de texto"
            confianca = 0.0
            marcadores = []

        resultados_nlp.append({
            'risco_texto': risco_texto,
            'confianca': confianca,
            'marcadores': marcadores
        })

    # 5. Gerar os arquivos TXT unificados
    print("[GERAÇÃO] Criando relatórios na pasta 'relatorios_txt'...")
    arquivos_gerados = gerar_arquivos_txt(
        df_pacientes=df_pacientes, 
        previsoes_rf=previsoes_rf,
        textos=textos_analisados,
        resultados_nlp=resultados_nlp
    )
    
    print(f"[SUCESSO] {len(arquivos_gerados)} relatórios foram gerados e salvos localmente.")

if __name__ == "__main__":
    gerar_relatorios_do_banco()