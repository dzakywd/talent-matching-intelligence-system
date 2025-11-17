CREATE TABLE IF NOT EXISTS tv_variables (
  tgv_name TEXT NOT NULL,
  tv_name TEXT NOT NULL,
  column_name TEXT NOT NULL,
  scoring_direction TEXT NOT NULL,    -- 'higher' | 'lower' | 'boolean'
  tv_weight NUMERIC DEFAULT NULL
);

INSERT INTO public.tv_variables (tgv_name, tv_name, column_name, scoring_direction) VALUES
  ('Competency','IDS_2025','ids_2025','higher'),
  ('Competency','SEA_2025','sea_2025','higher'),
  ('Competency','CSI_2025','csi_2025','higher'),
  ('Competency','STO_2025','sto_2025','higher'),
  ('Competency','LIE_2025','lie_2025','higher'),
  ('Competency','GDR_2025','gdr_2025','higher'),
  ('Competency','QDD_2025','qdd_2025','higher'),
  ('Competency','CEX_2025','cex_2025','higher'),
  ('Competency','VCU_2025','vcu_2025','higher'),
  ('Competency','FTC_2025','ftc_2025','higher'),

  ('Cognitive','PAULI','pauli','higher'),
  ('Cognitive','GTQ','gtq','higher'),

  ('Personality','MBTI_ISFP','mbti_isfp','boolean'),
  ('Personality','MBTI_ENFP','mbti_enfp','boolean'),

  ('WorkPref','PAPI_P','papi_p','higher'),

  ('Strengths','Connectedness','str_connectedness','higher'),
  ('Strengths','Individualization','str_individualization','higher'),
  ('Strengths','Self_Assurance','str_self_assurance','higher'),
  ('Strengths','Focus','str_focus','higher');
