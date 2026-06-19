import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# Atualizado com as colunas exatas da sua tabela do Supabase
FEATURES = [
    'humor',
    'horasSono',
    'nivelEstresse',
    'atividadeFisica',
    'interacaoSocial'
]

# Você precisará criar esta coluna no Supabase para salvar o resultado
TARGET = 'risco_classificado'

def instanciar_e_treinar_modelo(df_treino: pd.DataFrame) -> RandomForestClassifier:
    X = df_treino[FEATURES]
    y = df_treino[TARGET]

    modelo_rf = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, class_weight='balanced')
    modelo_rf.fit(X, y)
    return modelo_rf

def gerar_arquivos_txt(df_pacientes: pd.DataFrame, previsoes: list) -> list:
    pasta_destino = "relatorios_txt"
    os.makedirs(pasta_destino, exist_ok=True)
    arquivos_gerados = []

    for index, row in df_pacientes.iterrows():
        id_checkin = row['id']
        id_usuario = row['user_id']
        risco_calculado = previsoes[index]

        caminho_arquivo = f"{pasta_destino}/analise_{id_checkin}.txt"

        with open(caminho_arquivo, "w", encoding="utf-8") as file:
            file.write("=== RELATÓRIO DE MONITORAMENTO MULTIMODAL ===\n")
            file.write(f"ID Usuário: {id_usuario}\n")
            file.write(f"ID Check-in: {id_checkin}\n")
            file.write(f"Classificação Random Forest: {risco_calculado}\n")
            file.write("-" * 45 + "\n")
            file.write("Parâmetros Analisados:\n")
            for col in FEATURES:
                file.write(f"> {col}: {row[col]}\n")
        
        arquivos_gerados.append(caminho_arquivo)
        
    return arquivos_gerados