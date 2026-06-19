from fastapi import FastAPI, HTTPException, BackgroundTasks
from contextlib import asynccontextmanager
import pandas as pd

# Importações dos seus módulos internos
from core.database import supabase
from services.ml_pipeline import instanciar_e_treinar_modelo, gerar_arquivos_txt, FEATURES

# Variável global para manter o modelo carregado na memória RAM do servidor
modelo_rf_cache = None

def executar_pipeline_completo():
    global modelo_rf_cache

    try:
        print("\n--- [PIPELINE] Iniciando processamento de dados ---")

        if modelo_rf_cache is None:
            print("[PIPELINE] Buscando dados de treino na tabela 'checkins'...")

            # ATUALIZADO: Usando o .filter() cru para buscar onde NÃO É NULO
            resposta_treino = supabase.table("checkins").select("*").filter("risco_classificado", "not.is", "null").execute()
            df_treino = pd.DataFrame(resposta_treino.data)

            if df_treino.empty:
                print("[ERRO] Nenhum check-in com risco previamente classificado encontrado para treinar o modelo.")
                return

            modelo_rf_cache = instanciar_e_treinar_modelo(df_treino)
            print("[PIPELINE] Treinamento dinâmico concluído com sucesso.")

        print("[PIPELINE] Buscando novos check-ins para análise...")

        # ATUALIZADO: Usando o .filter() cru para buscar onde É NULO
        resposta_novos = supabase.table("checkins").select("*").filter("risco_classificado", "is", "null").execute()
        df_novos = pd.DataFrame(resposta_novos.data)

        if df_novos.empty:
            print("[PIPELINE] Nenhum check-in pendente encontrado para classificação.")
            return

        # Previsão
        X_novos = df_novos[FEATURES]
        previsoes = modelo_rf_cache.predict(X_novos)

        # Geração de TXT
        arquivos = gerar_arquivos_txt(df_novos, previsoes)
        print(f"[PIPELINE] Sucesso! {len(arquivos)} relatórios gerados.")

        # Atualizar o Supabase com as previsões feitas
        for index, id_checkin in enumerate(df_novos['id']):
            supabase.table("checkins").update({"risco_classificado": previsoes[index]}).eq("id", id_checkin).execute()

    except Exception as e:
        print(f"[ERRO NO PIPELINE] Falha: {str(e)}")

# Gerenciador de ciclo de vida da API (Lifespan)
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Tudo o que for digitado aqui roda AUTOMATICAMENTE na inicialização do código Python
    print("\n[STARTUP] Servidor Python Iniciado. Executando varredura inicial...")
    executar_pipeline_completo()
    yield
    # Código que roda ao desligar o servidor (se necessário)
    print("[SHUTDOWN] Desligando o servidor da API...")


# Inicializa o FastAPI aplicando o ciclo de vida configurado acima
app = FastAPI(title="API de Classificação de Risco Automatizada", lifespan=lifespan)


@app.post("/reprocessar")
async def endpoint_reprocessar(background_tasks: BackgroundTasks):
    """
    Endpoint reativo. Sempre que houver uma nova entrada no banco, 
    este endpoint deve ser chamado para disparar a reanálise.
    """
    # Adiciona a tarefa para rodar de forma assíncrona em segundo plano,
    # liberando a resposta HTTP imediatamente sem travar a aplicação cliente.
    background_tasks.add_task(executar_pipeline_completo)
    
    return {
        "status": "sucesso",
        "mensagem": "Nova entrada detectada. Reprocessamento do Random Forest disparado em segundo plano."
    }