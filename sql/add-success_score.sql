ALTER TABLE df_master
ADD COLUMN success_score NUMERIC;

WITH stats AS (
    SELECT
        AVG(ids_2025) AS mean_ids, STDDEV(ids_2025) AS sd_ids,
        AVG(sea_2025) AS mean_sea, STDDEV(sea_2025) AS sd_sea,
        AVG(csi_2025) AS mean_csi, STDDEV(csi_2025) AS sd_csi,
        AVG(sto_2025) AS mean_sto, STDDEV(sto_2025) AS sd_sto,
        AVG(lie_2025) AS mean_lie, STDDEV(lie_2025) AS sd_lie,
        AVG(gdr_2025) AS mean_gdr, STDDEV(gdr_2025) AS sd_gdr,
        AVG(qdd_2025) AS mean_qdd, STDDEV(qdd_2025) AS sd_qdd,
        AVG(cex_2025) AS mean_cex, STDDEV(cex_2025) AS sd_cex,
        AVG(vcu_2025) AS mean_vcu, STDDEV(vcu_2025) AS sd_vcu,
        AVG(ftc_2025) AS mean_ftc, STDDEV(ftc_2025) AS sd_ftc,

        AVG(pauli) AS mean_pauli, STDDEV(pauli) AS sd_pauli,
        AVG(gtq) AS mean_gtq, STDDEV(gtq) AS sd_gtq,

        AVG(papi_p) AS mean_papi_p, STDDEV(papi_p) AS sd_papi_p,

        AVG(str_connectedness) AS mean_str_connectedness, STDDEV(str_connectedness) AS sd_str_connectedness,
        AVG(str_individualization) AS mean_str_individualization, STDDEV(str_individualization) AS sd_str_individualization,
        AVG(str_self_assurance) AS mean_str_self_assurance, STDDEV(str_self_assurance) AS sd_str_self_assurance
    FROM df_master
),

normalized AS (
    SELECT
        m.employee_id,

        (ids_2025 - mean_ids) / NULLIF(sd_ids,0) AS ids_2025_norm,
        (sea_2025 - mean_sea) / NULLIF(sd_sea,0) AS sea_2025_norm,
        (csi_2025 - mean_csi) / NULLIF(sd_csi,0) AS csi_2025_norm,
        (sto_2025 - mean_sto) / NULLIF(sd_sto,0) AS sto_2025_norm,
        (lie_2025 - mean_lie) / NULLIF(sd_lie,0) AS lie_2025_norm,
        (gdr_2025 - mean_gdr) / NULLIF(sd_gdr,0) AS gdr_2025_norm,
        (qdd_2025 - mean_qdd) / NULLIF(sd_qdd,0) AS qdd_2025_norm,
        (cex_2025 - mean_cex) / NULLIF(sd_cex,0) AS cex_2025_norm,
        (vcu_2025 - mean_vcu) / NULLIF(sd_vcu,0) AS vcu_2025_norm,
        (ftc_2025 - mean_ftc) / NULLIF(sd_ftc,0) AS ftc_2025_norm,

        (pauli - mean_pauli) / NULLIF(sd_pauli,0) AS pauli_norm,
        (gtq - mean_gtq) / NULLIF(sd_gtq,0) AS gtq_norm,

        CASE WHEN mbti_isfp THEN 1 ELSE 0 END AS mbti_isfp_norm,
        CASE WHEN mbti_enfp THEN 1 ELSE 0 END AS mbti_enfp_norm,

        (papi_p - mean_papi_p) / NULLIF(sd_papi_p,0) AS papi_p_norm,

        (str_connectedness - mean_str_connectedness) / NULLIF(sd_str_connectedness,0) AS str_connectedness_norm,
        (str_individualization - mean_str_individualization) / NULLIF(sd_str_individualization,0) AS str_individualization_norm,
        (str_self_assurance - mean_str_self_assurance) / NULLIF(sd_str_self_assurance,0) AS str_self_assurance_norm
    FROM df_master m, stats
),

final_score AS (
    SELECT
        employee_id,
          0.096808 * ids_2025_norm
        + 0.096798 * sea_2025_norm
        + 0.096597 * csi_2025_norm
        + 0.096414 * sto_2025_norm
        + 0.096402 * lie_2025_norm
        + 0.096348 * gdr_2025_norm
        + 0.096029 * qdd_2025_norm
        + 0.095782 * cex_2025_norm
        + 0.095069 * vcu_2025_norm
        + 0.094819 * ftc_2025_norm
        + 0.006845 * pauli_norm
        + 0.004400 * gtq_norm
        + 0.004525 * mbti_isfp_norm
        + 0.003863 * mbti_enfp_norm
        + 0.005685 * papi_p_norm
        + 0.004967 * str_connectedness_norm
        + 0.004526 * str_individualization_norm
        + 0.004123 * str_self_assurance_norm
        AS success_score_calc
    FROM normalized
)

UPDATE df_master d
SET success_score = fs.success_score_calc
FROM final_score fs
WHERE d.employee_id = fs.employee_id;
