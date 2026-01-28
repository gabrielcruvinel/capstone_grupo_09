-- TABELA CLIENTE
CREATE TABLE tb_cliente (
    id_cli      INT PRIMARY KEY,           -- Identificador Único (Chave Primária)
    nm_cli      VARCHAR(100) NOT NULL,    -- Nome do Cliente
    dt_nsct_cli DATE,                      -- Data de Nascimento
    email_cli   VARCHAR(150),              -- E-mail
    tel_cli     VARCHAR(20),               -- Telefone
    end_cli     VARCHAR(200),              -- Endereço (Logradouro, número)
    munic_cli   VARCHAR(100),              -- Município
    uf_cli      CHAR(2),                   -- Estado (Ex: SP, RJ, MG)
    cep_cli     CHAR(8),                   -- CEP (Apenas números)
    rend_cli    DECIMAL(10, 2),            -- Renda Mensal (Ex: 99999999.99)
    profi_cli   VARCHAR(100)               -- Profissão
);

-- TABELA CONTA
CREATE TABLE tb_conta (
    id_conta        VARCHAR(36) PRIMARY KEY,    -- UUID/String Única
    id_cli          INT NOT NULL,              -- FK para tb_cliente
    num_conta       VARCHAR(20) NOT NULL,      -- Número da conta bancária
    cod_agencia     VARCHAR(10),               -- Código da agência
    vlr_saldo_atual DECIMAL(18, 2) DEFAULT 0,  -- Saldo com 2 casas decimais
    vlr_limite_esp  DECIMAL(18, 2) DEFAULT 0,  -- Limite especial
    status_conta    VARCHAR(20),               -- Ex: ATIVA, BLOQUEADA
    dt_abertura     DATE,                      -- Data de abertura
    ind_cartao_deb  BOOLEAN,                   -- Indicador booleano (True/False)
    
    -- Definição da Chave Estrangeira
    CONSTRAINT fk_cliente_conta 
        FOREIGN KEY (id_cli) 
        REFERENCES tb_cliente (id_cli)
        ON DELETE CASCADE                      -- Se o cliente for deletado, as contas também serão
);


-- TABELA CARTAO
CREATE TABLE tb_cartao (
    id_cartao       VARCHAR(36) PRIMARY KEY,    -- UUID Único
    id_conta        VARCHAR(36) NOT NULL,       -- FK para tb_conta
    bandeira_cartao VARCHAR(20),                -- Ex: VISA, MASTERCARD
    categoria_cartao VARCHAR(30),               -- Ex: GOLD, PLATINUM, BLACK
    num_cartao_final VARCHAR(4),                -- Apenas os 4 últimos dígitos
    dt_validade     VARCHAR(5),                 -- Formato MM/YY
    vlr_limite_tot  DECIMAL(18, 2),             -- Limite total aprovado
    vlr_limite_disp DECIMAL(18, 2),             -- Limite disponível no momento
    dia_vencimento  INT,                        -- Dia do mês (1 a 31)
    status_cartao   VARCHAR(20),                -- Ex: ATIVO, BLOQUEADO, CANCELADO
    
    CONSTRAINT fk_conta_cartao 
        FOREIGN KEY (id_conta) 
        REFERENCES tb_conta (id_conta)
        ON DELETE CASCADE
);

-- TABELA FATURA_CARTAO

CREATE TABLE tb_fatura_cartao (
    id_fatura            VARCHAR(36) PRIMARY KEY,    -- UUID Único
    id_cartao            VARCHAR(36) NOT NULL,       -- FK para tb_cartao
    mes_ref              VARCHAR(7),                 -- Formato YYYY-MM
    dt_fechamento        DATE,                       -- Data de corte
    dt_vencimento        DATE,                       -- Data de pagamento
    vlr_compras_mes      DECIMAL(18, 2),             -- Gastos no período
    vlr_saldo_anterior   DECIMAL(18, 2),             -- O que restou do mês passado
    vlr_encargos_totais  DECIMAL(18, 2),             -- Juros e multas
    vlr_ajustes_creditos DECIMAL(18, 2),             -- Estornos ou pagamentos
    vlr_total_fatura     DECIMAL(18, 2),             -- Valor final (Calculado)
    vlr_minimo           DECIMAL(18, 2),             -- Valor para pagamento mínimo
    status_fatura        VARCHAR(20),                -- ABERTA, FECHADA, PAGA, ATRASADA
    
    CONSTRAINT fk_cartao_fatura 
        FOREIGN KEY (id_cartao) 
        REFERENCES tb_cartao (id_cartao)
        ON DELETE CASCADE
);

-- TABELA EXTRATO

CREATE TABLE tb_extrato (
    id_movimentacao    VARCHAR(36) PRIMARY KEY,    -- UUID Único
    id_conta           VARCHAR(36) NOT NULL,       -- FK para tb_conta
    ts_movimentacao    TIMESTAMP, -- Data e Hora exata
    dt_contabil        DATE,                       -- Data que o valor efetivou
    vlr_transacao      DECIMAL(18, 2) NOT NULL,    -- Valor da movimentação
    tp_operacao        VARCHAR(10),                -- 'CREDITO' ou 'DEBITO'
    ds_historico       VARCHAR(255),               -- Descrição (ex: "PIX Recebido")
    vlr_saldo_pos_mov  DECIMAL(18, 2),             -- Saldo da conta após a operação
    tp_instrumento     VARCHAR(50),                -- PIX, CARTAO, BOLETO, TED
    id_transacao_ref   VARCHAR(36),                -- Referência cruzada
    
    CONSTRAINT fk_conta_extrato 
        FOREIGN KEY (id_conta) 
        REFERENCES tb_conta (id_conta)
        ON DELETE CASCADE
);

-- TABELA PAGAMENTO_FATURA
CREATE TABLE tb_pagamento_fatura (
    id_pagamento     VARCHAR(36) PRIMARY KEY,    -- UUID Único
    id_fatura        VARCHAR(36) NOT NULL,       -- FK para tb_fatura_cartao
    ts_pagamento     TIMESTAMP,                  -- Momento exato do pagamento
    dt_liquidacao    DATE,                       -- Data de compensação bancária
    vlr_pago         DOUBLE PRECISION,           -- Valor pago pelo cliente
    meio_pagamento   VARCHAR(50),                -- PIX, BOLETO, SALDO_CONTA
    tp_pagamento     VARCHAR(20),                -- TOTAL, PARCIAL, MINIMO
    ind_atraso       BOOLEAN,                    -- Indicador de atraso
    id_autenticacao  VARCHAR(100),               -- Código de autenticação/comprovante
    
    CONSTRAINT fk_fatura_pagamento 
        FOREIGN KEY (id_fatura) 
        REFERENCES tb_fatura_cartao (id_fatura)
        ON DELETE CASCADE
);

-- TABELA TRANSACOES CARTAO
CREATE TABLE tb_transacoes_cartao (
    id_transacao      VARCHAR(36) PRIMARY KEY,    -- UUID Único
    id_cartao         VARCHAR(36) NOT NULL,       -- FK para tb_cartao
    ts_transacao      TIMESTAMP,                  -- Data e hora da compra
    vlr_transacao     DECIMAL(18, 2) NOT NULL,    -- Valor da compra
    nm_estabelecimento VARCHAR(150),              -- Nome da loja/estabelecimento
    categoria_trans   VARCHAR(50),                -- Alimentação, Lazer, etc.
    qtde_parcelas     INT DEFAULT 1,              -- 1 para à vista, >1 para parcelado
    num_parcela       INT DEFAULT 1,              -- Qual parcela é esta
    ind_contato       BOOLEAN,                    -- Se foi por aproximação (NFC)
    status_transacao  VARCHAR(20),                -- APROVADA, NEGADA, ESTORNADA
    
    CONSTRAINT fk_cartao_transacao 
        FOREIGN KEY (id_cartao) 
        REFERENCES tb_cartao (id_cartao)
        ON DELETE CASCADE
);