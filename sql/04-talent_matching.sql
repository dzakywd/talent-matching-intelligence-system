WITH tb AS (
    SELECT *
    FROM public.talent_benchmarks
    WHERE job_vacancy_id = 'VAC001'
),

-- STEP 1: Baseline (median) for each TV based on benchmark talents
benchmark AS (
    SELECT
        tv.tgv_name,
        tv.tv_name,
        tv.column_name,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY
                CASE tv.column_name
                    WHEN 'ids_2025' THEN dm.ids_2025
                    WHEN 'sea_2025' THEN dm.sea_2025
                    WHEN 'csi_2025' THEN dm.csi_2025
                    WHEN 'sto_2025' THEN dm.sto_2025
                    WHEN 'lie_2025' THEN dm.lie_2025
                    WHEN 'gdr_2025' THEN dm.gdr_2025
                    WHEN 'qdd_2025' THEN dm.qdd_2025
                    WHEN 'cex_2025' THEN dm.cex_2025
                    WHEN 'vcu_2025' THEN dm.vcu_2025
                    WHEN 'ftc_2025' THEN dm.ftc_2025

                    WHEN 'pauli' THEN dm.pauli
                    WHEN 'gtq' THEN dm.gtq
                    WHEN 'papi_p' THEN dm.papi_p

                    WHEN 'str_connectedness' THEN dm.str_connectedness
                    WHEN 'str_individualization' THEN dm.str_individualization
                    WHEN 'str_self_assurance' THEN dm.str_self_assurance
                    WHEN 'str_focus' THEN dm.str_focus

                    WHEN 'mbti_isfp' THEN CASE WHEN dm.mbti_isfp THEN 1 ELSE 0 END
                    WHEN 'mbti_enfp' THEN CASE WHEN dm.mbti_enfp THEN 1 ELSE 0 END
                END
        ) AS baseline_score

    FROM public.tv_variables tv
    CROSS JOIN LATERAL (
        SELECT dm.*
        FROM public.df_master dm
        WHERE dm.employee_id IN (
            SELECT UNNEST(selected_talent_ids)
            FROM tb
        )
    ) dm
    GROUP BY tv.tgv_name, tv.tv_name, tv.column_name
),

-- STEP 2: Extract candidate scores for each TV
candidate_scores AS (
    SELECT
        dm.employee_id,
        tv.tgv_name,
        tv.tv_name,

        CASE tv.column_name
            WHEN 'ids_2025' THEN dm.ids_2025
            WHEN 'sea_2025' THEN dm.sea_2025
            WHEN 'csi_2025' THEN dm.csi_2025
            WHEN 'sto_2025' THEN dm.sto_2025
            WHEN 'lie_2025' THEN dm.lie_2025
            WHEN 'gdr_2025' THEN dm.gdr_2025
            WHEN 'qdd_2025' THEN dm.qdd_2025
            WHEN 'cex_2025' THEN dm.cex_2025
            WHEN 'vcu_2025' THEN dm.vcu_2025
            WHEN 'ftc_2025' THEN dm.ftc_2025

            WHEN 'pauli' THEN dm.pauli
            WHEN 'gtq' THEN dm.gtq
            WHEN 'papi_p' THEN dm.papi_p

            WHEN 'str_connectedness' THEN dm.str_connectedness
            WHEN 'str_individualization' THEN dm.str_individualization
            WHEN 'str_self_assurance' THEN dm.str_self_assurance
            WHEN 'str_focus' THEN dm.str_focus

            WHEN 'mbti_isfp' THEN CASE WHEN dm.mbti_isfp THEN 1 ELSE 0 END
            WHEN 'mbti_enfp' THEN CASE WHEN dm.mbti_enfp THEN 1 ELSE 0 END
        END::numeric AS user_score,

        dm.directorate_id,
        dm.position_id,
        dm.grade_id

    FROM public.df_master dm
    JOIN public.tv_variables tv ON TRUE
),

-- STEP 3: Match rate for each TV
tv_match AS (
    SELECT
        cs.employee_id,
        cs.tgv_name,
        cs.tv_name,
        cs.user_score,
        b.baseline_score,
        tv.scoring_direction,

        CASE
            WHEN tv.scoring_direction = 'higher' THEN
                (cs.user_score / NULLIF(b.baseline_score, 0)) * 100

            WHEN tv.scoring_direction = 'lower' THEN
                ((2 * b.baseline_score - cs.user_score) / NULLIF(b.baseline_score, 0)) * 100

            WHEN tv.scoring_direction = 'boolean' THEN
                CASE
                    WHEN cs.user_score = b.baseline_score THEN 100
                    ELSE 0
                END
        END AS tv_match_rate,

        cs.directorate_id,
        cs.position_id,
        cs.grade_id

    FROM candidate_scores cs
    JOIN benchmark b ON cs.tv_name = b.tv_name
    JOIN public.tv_variables tv ON cs.tv_name = tv.tv_name
),

-- STEP 4: TGV match = average of TV match per TGV
tgv_match AS (
    SELECT
        employee_id,
        tgv_name,
        AVG(tv_match_rate) AS tgv_match_rate
    FROM tv_match
    GROUP BY employee_id, tgv_name
),

-- STEP 5: Final match = average TGV score
final_match AS (
    SELECT
        employee_id,
        AVG(tgv_match_rate) AS final_match_rate
    FROM tgv_match
    GROUP BY employee_id
)

-- FINAL OUTPUT
SELECT
    tm.employee_id,
    tm.directorate_id AS directorate,
    tm.position_id AS role,
    tm.grade_id AS grade,
    tm.tgv_name,
    tm.tv_name,
    tm.baseline_score,
    tm.user_score,
    ROUND(tm.tv_match_rate::numeric, 2)::text || '%' AS tv_match_rate,
    ROUND(tgv.tgv_match_rate::numeric, 2)::text || '%' AS tgv_match_rate,
    ROUND(fm.final_match_rate::numeric, 2)::text || '%' AS final_match_rate

FROM tv_match tm
LEFT JOIN tgv_match tgv
    ON tm.employee_id = tgv.employee_id
   AND tm.tgv_name = tgv.tgv_name
LEFT JOIN final_match fm
    ON tm.employee_id = fm.employee_id

ORDER BY fm.final_match_rate DESC NULLS LAST;
