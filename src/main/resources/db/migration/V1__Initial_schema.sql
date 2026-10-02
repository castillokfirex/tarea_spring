-- =====================================================================
-- SCHEMA VERIFICADO CONTRA LAS 5 IMÁGENES EN ALTA RESOLUCIÓN
-- =====================================================================
-- Este archivo reemplaza la versión anterior (reconstruida desde una
-- sola imagen de baja resolución). Cada tabla de este archivo fue leída
-- directamente de tus capturas en zoom, columna por columna.
--
-- CONVENCIÓN DE NULABILIDAD usada en tu diagrama (deducida y confirmada
-- de forma consistente en decenas de columnas):
--   PK  = primary key
--   FK  = foreign key
--   U   = UNIQUE
--   N   = la columna SÍ admite NULL (nullable / opcional)
--   (sin marca) = NOT NULL
-- Lo apliqué así en todo el script.
--
-- Nota ortográfica: tu diagrama usa "statusses" (doble s) en el módulo
-- clínico (clinical_record_statusses, encounter_statusses,
-- treatment_statusses, treatment_goal_statusses) pero "statuses"
-- (una sola s) en el módulo de chat/IA (conversations_statuses,
-- ai_runs_statuses, escalations_statuses). No es un error mío: así
-- aparece literalmente en tu diagrama, y lo respeté tal cual para que
-- los nombres de FK coincidan exactamente con las tablas.
--
-- Puntos que quedaron marcados con "-- (revisar)" porque tu propio
-- diagrama parece tener una inconsistencia (no porque yo no pudiera
-- leerlos — esos ya los verifiqué con zoom):
--   1. ai_models.provider_model_id es VARCHAR(50) y está marcado FK,
--      pero provider_models_ai.id es UUID. Los tipos no coinciden, así
--      que no puedo crear la FK real; dejé la columna sin REFERENCES.
--   2. treatment_goals tiene una FK llamada literalmente
--      "treatment_goal_id", pero por la línea de relación del diagrama
--      apunta a treatment_goal_statusses. Mantuve el nombre tal como
--      está escrito y la referencia según la relación visual.
--   3. patient_allergies.recorded_by y chat_conversations.closed_by son
--      UUID pero NO están marcados como FK en tu diagrama (a diferencia
--      de otras columnas "_by" que sí lo están), así que los dejé sin
--      REFERENCES.
--   4. provider_models_ai.isActive está en camelCase en tu diagrama
--      (el resto del esquema usa snake_case); lo dejé igual.
--   5. city_municipalities: la columna se ve como "code_citi" en el
--      diagrama; asumí que es "code_city" (como en el resto de catálogos
--      geográficos), pero vale la pena que lo confirmes.
--
-- Tablas que NO aparecían en las 5 imágenes nuevas (resource_types,
-- resource_locations, resource_statuses) se mantienen tal como las
-- había inferido antes, SIN verificar — siguen marcadas "(inferida)".
-- Si tienes capturas de esa zona o de alguna otra que falte, las ajusto.
--
-- Motor objetivo: PostgreSQL.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- para gen_random_uuid()

-- =====================================================================
-- 1. CATÁLOGOS INDEPENDIENTES
-- =====================================================================

CREATE TABLE document_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE genders (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    description VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE professional_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(40) NOT NULL UNIQUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE relationship_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    description VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE studies (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(40) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE countries (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_country      VARCHAR(50)  NOT NULL,
    code_country      VARCHAR(10),
    description       VARCHAR(100),
    is_active         BOOLEAN      NOT NULL,
    telephone_prefix  VARCHAR(5),
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now()
);

-- --- Catálogos clínicos (ojo con "statusses" / "statuses", ver nota arriba) --

CREATE TABLE clinical_record_statusses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE encounter_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE encounter_modalities (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE encounter_statusses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE risk_levels (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    severity    INTEGER,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE treatment_statusses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE treatment_goal_statusses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE medication_routes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL UNIQUE,
    active      BOOLEAN     NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE assessment_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    description TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE consent_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    description TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE diagnostic_systems (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL UNIQUE,  -- p.ej. "CIE-10", "DSM-5"
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL,
    version     VARCHAR(20),
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

-- --- Catálogos de recursos: NO estaban en las 5 imágenes nuevas, se   --
-- --- mantienen sin verificar desde la versión anterior (inferidas).  --

CREATE TABLE resource_types ( -- (inferida, sin verificar en esta ronda)
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE resource_locations ( -- (inferida, sin verificar en esta ronda)
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE resource_statuses ( -- (inferida, sin verificar en esta ronda)
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code        VARCHAR(20) NOT NULL,
    name        VARCHAR(50) NOT NULL,
    active      BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

-- --- Catálogos del módulo de chat / IA (usan "statuses", una sola s) --

CREATE TABLE priorities (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_priority VARCHAR(50) NOT NULL,
    created_at    TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE conversations_statuses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_status VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE sender_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_type   VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE message_types (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_type   VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE ai_runs_statuses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_status VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE escalations_statuses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_status VARCHAR(50) NOT NULL,
    created_at  TIMESTAMP   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE provider_models_ai (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_provider_ai  VARCHAR(100) NOT NULL,
    razon_social      VARCHAR(100),
    sitio_web         TEXT,
    "isActive"        BOOLEAN      NOT NULL, -- camelCase tal como está en el diagrama
    created_at        TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMP    NOT NULL DEFAULT now()
);

-- =====================================================================
-- 2. GEOGRAFÍA (país -> región -> ciudad)
-- =====================================================================

CREATE TABLE state_regions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_region  VARCHAR(50)  NOT NULL,
    code_region  VARCHAR(10),
    description  VARCHAR(100),
    is_active    BOOLEAN      NOT NULL,
    country_id   UUID         NOT NULL REFERENCES countries(id),
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE city_municipalities (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_city    VARCHAR(50)  NOT NULL,
    code_city    VARCHAR(10), -- (revisar) se ve como "code_citi" en el diagrama
    description  VARCHAR(100),
    is_active    BOOLEAN      NOT NULL,
    region_id    UUID         NOT NULL REFERENCES state_regions(id),
    created_at   TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);

-- =====================================================================
-- 3. PERSONAS
-- =====================================================================

CREATE TABLE patients (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type_id    UUID         NOT NULL REFERENCES document_types(id),
    document_number     VARCHAR(30)  NOT NULL,
    first_name          VARCHAR(50)  NOT NULL,
    middle_name         VARCHAR(50),
    last_name           VARCHAR(50)  NOT NULL,
    second_last_name    VARCHAR(50),
    birth_date          DATE         NOT NULL,
    biological_sex_id   UUID         NOT NULL REFERENCES genders(id),
    gender_identity     UUID         NOT NULL REFERENCES genders(id),
    email               VARCHAR(150) NOT NULL UNIQUE,
    phone               VARCHAR(30)  NOT NULL,
    address              VARCHAR(250) NOT NULL,
    active              BOOLEAN      NOT NULL,
    created_at          TIMESTAMP    NOT NULL DEFAULT now(),
    created_by          UUID,
    updated_at          TIMESTAMP    NOT NULL DEFAULT now(),
    updated_by          UUID,
    city_id             UUID         NOT NULL REFERENCES city_municipalities(id),
    UNIQUE (document_type_id, document_number)
);

CREATE TABLE patient_allergies (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    UUID         NOT NULL REFERENCES patients(id),
    substance     VARCHAR(200) NOT NULL,
    reaction      TEXT,
    severity      VARCHAR(20)  NOT NULL,
    active        BOOLEAN      NOT NULL,
    recorded_at   TIMESTAMP    NOT NULL DEFAULT now(),
    recorded_by   UUID         NOT NULL, -- (revisar) sin marca FK en el diagrama
    created_at    TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE professionals (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type_id   UUID         NOT NULL REFERENCES document_types(id),
    document_number    VARCHAR(30)  NOT NULL UNIQUE,
    first_name         VARCHAR(60)  NOT NULL UNIQUE, -- (revisar) único por diagrama; raro a nivel de diseño
    last_name          VARCHAR(60)  NOT NULL UNIQUE, -- (revisar) único por diagrama; raro a nivel de diseño
    professional_type  UUID         NOT NULL REFERENCES professional_types(id),
    license_number     VARCHAR(100) NOT NULL UNIQUE,
    active             BOOLEAN      NOT NULL,
    city_id            UUID         NOT NULL REFERENCES city_municipalities(id),
    created_at         TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at         TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE professional_studies (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    study_id             UUID         NOT NULL REFERENCES studies(id),
    professional_id      UUID         NOT NULL REFERENCES professionals(id),
    title                VARCHAR(100) NOT NULL,
    university           VARCHAR(100) NOT NULL,
    is_valid             BOOLEAN      NOT NULL,
    resolution_number    VARCHAR(60),
    country_id           UUID         NOT NULL REFERENCES countries(id),
    created_at           TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at           TIMESTAMP    NOT NULL DEFAULT now()
);

-- =====================================================================
-- 4. CONTACTOS
-- =====================================================================

CREATE TABLE contacts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name   VARCHAR(200) NOT NULL,
    email       VARCHAR(150) NOT NULL,
    notes       TEXT         NOT NULL,
    city_id     UUID         NOT NULL REFERENCES city_municipalities(id),
    created_at  TIMESTAMP    NOT NULL DEFAULT now(),
    created_by  UUID         NOT NULL,
    updated_at  TIMESTAMP    NOT NULL DEFAULT now(),
    updated_by  UUID
);

CREATE TABLE phone_contacts ( -- esta tabla NO tiene created_at/updated_at en el diagrama
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id  UUID        NOT NULL REFERENCES contacts(id),
    phone       VARCHAR(30) NOT NULL,
    notes       TEXT
);

CREATE TABLE email_contacts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id  UUID         NOT NULL REFERENCES contacts(id),
    email       VARCHAR(150) NOT NULL UNIQUE,
    notes       TEXT         NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE patient_contacts ( -- esta tabla NO tiene created_at/updated_at en el diagrama
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id            UUID    NOT NULL REFERENCES contacts(id),
    patient_id            UUID    NOT NULL REFERENCES patients(id),
    is_primary_contact    BOOLEAN NOT NULL,
    is_emergency_contact  BOOLEAN NOT NULL,
    relationship_type_id  UUID    NOT NULL REFERENCES relationship_types(id)
);

-- =====================================================================
-- 5. MÓDULO CLÍNICO
-- =====================================================================

CREATE TABLE clinical_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id      UUID        NOT NULL REFERENCES patients(id),
    creation_date   TIMESTAMP   NOT NULL DEFAULT now(),
    record_number   VARCHAR(50) NOT NULL UNIQUE,
    opened_at       TIMESTAMP   NOT NULL DEFAULT now(),
    closed_at       TIMESTAMP,
    status_id       UUID        NOT NULL REFERENCES clinical_record_statusses(id),
    created_at      TIMESTAMP   NOT NULL DEFAULT now(),
    created_by      UUID        NOT NULL REFERENCES professionals(id)
);

CREATE TABLE encounters (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinical_record_id  UUID      NOT NULL REFERENCES clinical_records(id),
    professional_id     UUID      NOT NULL REFERENCES professionals(id),
    encounter_type_id   UUID      NOT NULL REFERENCES encounter_types(id),
    started_at          TIMESTAMP NOT NULL DEFAULT now(),
    ended_at            TIMESTAMP,
    reason_for_visit    TEXT      NOT NULL,
    current_condition   TEXT      NOT NULL,
    modality_id         UUID      NOT NULL REFERENCES encounter_modalities(id),
    status_id           UUID      NOT NULL REFERENCES encounter_statusses(id),
    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    created_by          UUID      NOT NULL,
    updated_at          TIMESTAMP NOT NULL DEFAULT now(),
    updated_by          UUID      NOT NULL
);

CREATE TABLE clinical_notes ( -- formato SOAP
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id     UUID      NOT NULL REFERENCES encounters(id),
    professional_id  UUID      NOT NULL REFERENCES professionals(id),
    subjective       TEXT      NOT NULL,
    objective        TEXT      NOT NULL,
    assessment       TEXT      NOT NULL,
    plan             TEXT      NOT NULL,
    additional_notes TEXT      NOT NULL,
    signed_at        TIMESTAMP NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT now(),
    updated_at       TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE mental_status_exams (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id           UUID      NOT NULL REFERENCES encounters(id),
    appearance             TEXT      NOT NULL,
    behavior               TEXT      NOT NULL,
    attitude               TEXT      NOT NULL,
    consciousness          TEXT      NOT NULL,
    orientation            TEXT      NOT NULL,
    attention              TEXT      NOT NULL,
    memory                 TEXT      NOT NULL,
    speech                 TEXT      NOT NULL,
    mood                   TEXT      NOT NULL,
    affect                 TEXT      NOT NULL,
    thought_process        TEXT      NOT NULL,
    thought_content        TEXT      NOT NULL,
    perception             TEXT      NOT NULL,
    judgment               TEXT      NOT NULL,
    insight                TEXT      NOT NULL,
    psychomotor_activity   TEXT      NOT NULL,
    observations           TEXT      NOT NULL,
    created_at             TIMESTAMP NOT NULL DEFAULT now(),
    created_by             UUID      NOT NULL REFERENCES professionals(id)
);

CREATE TABLE risk_assessments (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id         UUID    NOT NULL REFERENCES encounters(id),
    risk_level_id        UUID    NOT NULL REFERENCES risk_levels(id),
    suicidal_ideation    BOOLEAN NOT NULL,
    suicide_plan         BOOLEAN NOT NULL,
    suicide_intent       BOOLEAN NOT NULL,
    self_harm            BOOLEAN NOT NULL,
    harm_to_others       BOOLEAN NOT NULL,
    risk_factors         TEXT    NOT NULL,
    protective_factors   TEXT    NOT NULL,
    clinical_actions     TEXT    NOT NULL,
    observations         TEXT    NOT NULL,
    assessed_at          TIMESTAMP NOT NULL DEFAULT now(),
    assessed_by          UUID    NOT NULL REFERENCES professionals(id)
);

CREATE TABLE treatment_plans (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    encounter_id         UUID         NOT NULL REFERENCES encounters(id),
    professional_id      UUID         NOT NULL REFERENCES professionals(id),
    title                VARCHAR(200) NOT NULL,
    description          TEXT         NOT NULL,
    start_date           DATE         NOT NULL,
    end_date             DATE         NOT NULL,
    treatment_status_id  UUID         NOT NULL REFERENCES treatment_statusses(id),
    created_at           TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at           TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE treatment_goals (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treatment_plan_id  UUID NOT NULL REFERENCES treatment_plans(id),
    description        TEXT NOT NULL,
    target_date        DATE NOT NULL,
    completed_at       TIMESTAMP,
    notes              TEXT NOT NULL,
    treatment_goal_id  UUID NOT NULL REFERENCES treatment_goal_statusses(id), -- (revisar) nombre ambiguo, ver nota arriba
    created_at         TIMESTAMP NOT NULL DEFAULT now(),
    updated_at         TIMESTAMP NOT NULL DEFAULT now()
);

-- =====================================================================
-- 6. MÓDULO DE CHAT / MENSAJERÍA / IA
-- =====================================================================

CREATE TABLE chat_conversations (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_status_id   UUID      NOT NULL REFERENCES conversations_statuses(id),
    priority_id              UUID      NOT NULL REFERENCES priorities(id),
    last_message_at          TIMESTAMP,
    closed                   BOOLEAN,
    closed_at                TIMESTAMP,
    closed_by                UUID, -- (revisar) sin marca FK en el diagrama
    created_at               TIMESTAMP NOT NULL DEFAULT now(),
    updated_at               TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_participants (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id       UUID NOT NULL REFERENCES chat_conversations(id),
    participant_type_id   UUID NOT NULL REFERENCES sender_types(id),
    patient_id            UUID REFERENCES patients(id),
    professional_id       UUID REFERENCES professionals(id),
    created_at            TIMESTAMP NOT NULL DEFAULT now(),
    updated_at            TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_messages (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id  UUID NOT NULL REFERENCES chat_conversations(id),
    message_type_id  UUID NOT NULL REFERENCES message_types(id),
    participant_id   UUID NOT NULL REFERENCES chat_participants(id),
    content          JSONB NOT NULL,
    metadata         JSONB NOT NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE ai_models (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_model_id    VARCHAR(50)  NOT NULL, -- (revisar) FK en el diagrama, pero el tipo no coincide con provider_models_ai.id (UUID); ver nota arriba
    name_model           VARCHAR(100) NOT NULL,
    model_key            VARCHAR(170) NOT NULL,
    input_token_price    DECIMAL(12,8) NOT NULL,
    output_token_price   DECIMAL(12,8) NOT NULL,
    max_tokens           INTEGER      NOT NULL,
    context_window       INTEGER      NOT NULL,
    is_active            BOOLEAN      NOT NULL,
    created_at           TIMESTAMP    NOT NULL DEFAULT now(),
    updated_at           TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE chat_conversation_ai_settings (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id    UUID    NOT NULL REFERENCES chat_conversations(id),
    ai_enabled         BOOLEAN NOT NULL,
    default_model_id   UUID    NOT NULL REFERENCES ai_models(id),
    created_at         TIMESTAMP NOT NULL DEFAULT now(),
    updated_at         TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_ai_runs (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id    UUID NOT NULL REFERENCES chat_conversations(id),
    message_id         UUID NOT NULL REFERENCES chat_messages(id),
    model_id           UUID NOT NULL REFERENCES ai_models(id),
    ai_run_status_id   UUID NOT NULL REFERENCES ai_runs_statuses(id),
    created_at         TIMESTAMP NOT NULL DEFAULT now(),
    updated_at         TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_ai_run_metrics (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ai_run_id           UUID NOT NULL REFERENCES chat_ai_runs(id),
    prompt_tokens       INTEGER NOT NULL,
    completion_tokens   INTEGER NOT NULL,
    total_tokens        INTEGER NOT NULL,
    cost                DECIMAL(10,6) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_ai_run_errors (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ai_run_id            UUID NOT NULL REFERENCES chat_ai_runs(id),
    error_message        TEXT NOT NULL,
    error_code           VARCHAR(80)  NOT NULL,
    provider_error_id    VARCHAR(120) NOT NULL,
    created_at           TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_escalations (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id   UUID NOT NULL REFERENCES chat_conversations(id),
    status_id         UUID NOT NULL REFERENCES escalations_statuses(id),
    from_ai           BOOLEAN NOT NULL,
    reason            TEXT NOT NULL,
    created_at        TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_escalation_assignments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escalation_id   UUID NOT NULL REFERENCES chat_escalations(id),
    professional_id UUID NOT NULL REFERENCES professionals(id),
    assigned_at     TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE chat_escalation_status_history (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    escalation_id          UUID NOT NULL REFERENCES chat_escalations(id),
    escalation_status_id   UUID NOT NULL REFERENCES escalations_statuses(id),
    created_at             TIMESTAMP NOT NULL DEFAULT now(),
    changed_at             TIMESTAMP NOT NULL
);

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
