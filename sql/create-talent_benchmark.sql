CREATE TABLE IF NOT EXISTS public.talent_benchmarks (
  job_vacancy_id TEXT PRIMARY KEY,
  role_name TEXT,
  job_level TEXT,
  role_purpose TEXT,
  selected_talent_ids TEXT[],   -- array of employee_id
  weights_config JSONB          -- optional custom weights (boleh null)
);

INSERT INTO public.talent_benchmarks (
    job_vacancy_id,
    role_name,
    job_level,
    role_purpose,
    selected_talent_ids
)
VALUES (
    'VAC001',
    'Sales Manager',
    'AMGR',
    'Drive sales performance and team execution.',
    (
        SELECT ARRAY(
            SELECT employee_id
            FROM df_master
            ORDER BY success_score DESC
            LIMIT 10
        )
    )
);
