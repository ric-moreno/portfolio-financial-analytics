SELECT 
    'fato_retornos_diarios' as tabela,
    COUNT(*) as total_linhas,
    COUNT(DISTINCT ativo) as qtd_ativos,
    MIN(date) as data_min,
    MAX(date) as data_max,
    SUM(CASE WHEN retorno_diario IS NULL THEN 1 ELSE 0 END) as valores_nulos
FROM financial_analytics.fato_retornos_diarios;


WITH returns_with_rolling_vol AS (
    SELECT 
        date,
        ativo,
        retorno_diario,
        STDDEV_POP(retorno_diario) OVER (
            PARTITION BY ativo 
            ORDER BY date 
            ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
        ) as std_dev_21d
    FROM financial_analytics.fato_retornos_diarios
)
SELECT 
    date,
    ativo,
    ROUND((retorno_diario * 100)::NUMERIC, 4) as retorno_diario_pct,
    ROUND((std_dev_21d * SQRT(252) * 100)::NUMERIC, 2) as volatilidade_mov_21d_anual_pct
FROM returns_with_rolling_vol
WHERE ativo IN ('VALE3.SA', '^BVSP') 
  AND date >= '2023-01-01'
ORDER BY date DESC;


WITH running_max AS (
    SELECT 
        date,
        ativo,
        retorno_acumulado,
        MAX(retorno_acumulado) OVER (
            PARTITION BY ativo 
            ORDER BY date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as pico_historico
    FROM financial_analytics.fato_retornos_acumulados
)
SELECT 
    date,
    ativo,
    ROUND((retorno_acumulado * 100)::NUMERIC, 2) as retorno_acumulado_pct,
    ROUND((pico_historico * 100)::NUMERIC, 2) as pico_historico_pct,
    ROUND((((retorno_acumulado - pico_historico) / (1 + pico_historico)) * 100)::NUMERIC, 2) as drawdown_atual_pct
FROM running_max
WHERE ativo = 'VALE3.SA'
ORDER BY date DESC
LIMIT 10;
