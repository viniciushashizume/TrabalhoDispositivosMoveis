import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

FEATURES = [
    'humor',
    'horasSono',
    'nivelEstresse',
    'atividadeFisica',
    'interacaoSocial'
]

TARGET = 'risco_classificado'

def instanciar_e_treinar_modelo(df_treino: pd.DataFrame) -> RandomForestClassifier:
    X = df_treino[FEATURES]
    y = df_treino[TARGET]

    modelo_rf = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, class_weight='balanced')
    modelo_rf.fit(X, y)
    return modelo_rf

def gerar_relatorios_checkin(df_checkins: pd.DataFrame, previsoes_rf: list, emails: list) -> list:
    base_destino = "relatorios_txt"
    arquivos_gerados = []

    for index, row in df_checkins.iterrows():
        id_checkin = row['id']
        email_usuario = emails[index]
        risco_calculado_rf = previsoes_rf[index]
        
        safe_email = "".join(c for c in email_usuario if c.isalnum() or c in "@.-_")
        pasta_usuario = os.path.join(base_destino, safe_email, "checkins")
        os.makedirs(pasta_usuario, exist_ok=True)

        caminho_arquivo = os.path.join(pasta_usuario, f"analise_{id_checkin}.txt")

        with open(caminho_arquivo, "w", encoding="utf-8") as file:
            file.write(f"Usuário / Email: {email_usuario}\n")
            file.write(f"ID Check-in: {id_checkin}\n")
            file.write("-" * 45 + "\n")
            file.write("Análise via ML - random forest\n")
            file.write(f"Classificação: {risco_calculado_rf}\n")
            file.write("Parâmetros Analisados:\n")
            for col in FEATURES:
                file.write(f"> {col}: {row.get(col, 'N/A')}\n")
            file.write("-" * 45 + "\n")
        
        arquivos_gerados.append(caminho_arquivo)
        
    return arquivos_gerados

def gerar_relatorios_diario(df_diarios: pd.DataFrame, resultados_nlp: list, emails: list) -> list:
    base_destino = "relatorios_txt"
    arquivos_gerados = []

    for index, row in df_diarios.iterrows():
        id_diario = row.get('id', f'unknown_{index}')
        email_usuario = emails[index]
        resultado = resultados_nlp[index]
        texto = row.get('content', '')
        
        safe_email = "".join(c for c in email_usuario if c.isalnum() or c in "@.-_")
        pasta_usuario = os.path.join(base_destino, safe_email, "diarios")
        os.makedirs(pasta_usuario, exist_ok=True)

        caminho_arquivo = os.path.join(pasta_usuario, f"analise_{id_diario}.txt")

        with open(caminho_arquivo, "w", encoding="utf-8") as file:
            file.write(f"Usuário / Email: {email_usuario}\n")
            file.write(f"ID Diário: {id_diario}\n")
            file.write("-" * 45 + "\n")
            file.write("Análise via NLP\n")
            file.write(f"Texto Analisado: \"{texto}\"\n")
            file.write(f"Classificação PLN: {resultado['risco_texto']}\n")
            marcadores_str = ', '.join(resultado['marcadores']) if resultado['marcadores'] else 'Nenhum'
            file.write(f"Marcadores Identificados: {marcadores_str}\n")
            file.write("-" * 45 + "\n")
        
        arquivos_gerados.append(caminho_arquivo)
        
    return arquivos_gerados