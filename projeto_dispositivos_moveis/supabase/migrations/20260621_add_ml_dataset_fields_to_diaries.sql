alter table public.diaries
    add column if not exists expected_risk text,
    add column if not exists expected_risk_binary smallint,
    add column if not exists expected_risk_score smallint,
    add column if not exists expected_categories text[],
    add column if not exists is_synthetic boolean not null default false,
    add column if not exists dataset_split text,
    add column if not exists label_source text,
    add column if not exists label_reviewed boolean not null default false,
    add column if not exists language text default 'pt-BR',
    add column if not exists mock_group_id text;

do $$
begin
    if not exists (
        select 1
        from pg_constraint
        where conname = 'diaries_expected_risk_check'
    ) then
        alter table public.diaries
            add constraint diaries_expected_risk_check
            check (expected_risk is null or expected_risk in ('baixo', 'alto'));
    end if;

    if not exists (
        select 1
        from pg_constraint
        where conname = 'diaries_expected_risk_binary_check'
    ) then
        alter table public.diaries
            add constraint diaries_expected_risk_binary_check
            check (
                expected_risk_binary is null
                or expected_risk_binary in (0, 1)
            );
    end if;

    if not exists (
        select 1
        from pg_constraint
        where conname = 'diaries_expected_risk_score_check'
    ) then
        alter table public.diaries
            add constraint diaries_expected_risk_score_check
            check (
                expected_risk_score is null
                or expected_risk_score between 0 and 3
            );
    end if;

    if not exists (
        select 1
        from pg_constraint
        where conname = 'diaries_dataset_split_check'
    ) then
        alter table public.diaries
            add constraint diaries_dataset_split_check
            check (
                dataset_split is null
                or dataset_split in ('train', 'validation', 'test')
            );
    end if;
end
$$;

create index if not exists diaries_ml_dataset_idx
    on public.diaries (is_synthetic, dataset_split, expected_risk);

comment on column public.diaries.expected_risk is
    'Rótulo supervisionado binário: baixo ou alto. Não usar como entrada do modelo.';

comment on column public.diaries.expected_risk_binary is
    'Target numérico compatível com o classificador: 0 para baixo e 1 para alto.';

comment on column public.diaries.expected_risk_score is
    'Intensidade esperada de 0 a 3. Metadado de avaliação, não feature de texto.';

comment on column public.diaries.expected_categories is
    'Categorias esperadas associadas ao texto, como ansiedade, pânico ou bem-estar.';

comment on column public.diaries.dataset_split is
    'Partição fixa do dataset: train, validation ou test.';

comment on column public.diaries.label_reviewed is
    'Indica se o rótulo foi revisado por pessoa qualificada.';
