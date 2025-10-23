-- ScoutAI Database Schema
-- PostgreSQL 15+
-- 3rd Normal Form 

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================
-- CORE ENTITIES
-- ==============================================

-- Leagues
CREATE TABLE leagues (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    country VARCHAR(100) NOT NULL,
    tier SMALLINT NOT NULL CHECK (tier > 0),
    has_advanced_stats BOOLEAN DEFAULT FALSE,
    fbref_id VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_league_tier CHECK (tier BETWEEN 1 AND 10)
);

CREATE INDEX idx_leagues_country ON leagues(country);
CREATE INDEX idx_leagues_tier ON leagues(tier);
CREATE INDEX idx_leagues_fbref_id ON leagues(fbref_id);

-- Teams
CREATE TABLE teams (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    league_id BIGINT REFERENCES leagues(id) ON DELETE SET NULL,
    country VARCHAR(100),
    stadium VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_team_name_length CHECK (LENGTH(name) >= 2)
);

CREATE INDEX idx_teams_name ON teams(name);
CREATE INDEX idx_teams_league_id ON teams(league_id);
CREATE INDEX idx_teams_country ON teams(country);

-- Seasons
CREATE TABLE seasons (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    start_year SMALLINT NOT NULL,
    end_year SMALLINT NOT NULL,
    
    CONSTRAINT chk_season_years CHECK (end_year >= start_year),
    CONSTRAINT chk_season_year_range CHECK (start_year >= 2000 AND end_year <= 2100)
);

CREATE INDEX idx_seasons_start_year ON seasons(start_year);

-- Matchdays
CREATE TABLE matchdays (
    id BIGSERIAL PRIMARY KEY,
    league_id BIGINT NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    season_id BIGINT NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    matchday_number SMALLINT NOT NULL CHECK (matchday_number > 0),
    date_start DATE NOT NULL,
    date_end DATE,
    
    CONSTRAINT uq_matchday UNIQUE (league_id, season_id, matchday_number),
    CONSTRAINT chk_matchday_dates CHECK (date_end IS NULL OR date_end >= date_start)
);

CREATE INDEX idx_matchdays_league_season ON matchdays(league_id, season_id);
CREATE INDEX idx_matchdays_date_start ON matchdays(date_start);

-- ==============================================
-- PLAYER ENTITIES
-- ==============================================

-- Players
CREATE TABLE players (
    id BIGSERIAL PRIMARY KEY,
    transfermarkt_id VARCHAR(50) UNIQUE,
    fbref_id VARCHAR(50) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality VARCHAR(100),
    height_cm SMALLINT CHECK (height_cm IS NULL OR height_cm BETWEEN 150 AND 220),
    foot VARCHAR(10) CHECK (foot IN ('left', 'right', 'both')),
    current_team_id BIGINT REFERENCES teams(id) ON DELETE SET NULL,
    current_market_value_eur INTEGER CHECK (current_market_value_eur IS NULL OR current_market_value_eur >= 0),
    contract_expires DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_player_name_length CHECK (LENGTH(full_name) >= 2),
    CONSTRAINT chk_player_dob CHECK (date_of_birth >= '1950-01-01' AND date_of_birth <= CURRENT_DATE)
);

CREATE INDEX idx_players_full_name ON players(full_name);
CREATE INDEX idx_players_dob ON players(date_of_birth);
CREATE INDEX idx_players_nationality ON players(nationality);
CREATE INDEX idx_players_transfermarkt_id ON players(transfermarkt_id);
CREATE INDEX idx_players_fbref_id ON players(fbref_id);
CREATE INDEX idx_players_current_team ON players(current_team_id);

-- Positions
CREATE TABLE positions (
    id SMALLSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    position_group VARCHAR(20) NOT NULL CHECK (position_group IN ('Goalkeeper', 'Defender', 'Midfielder', 'Forward'))
);

-- Insert standard positions
INSERT INTO positions (name, position_group) VALUES
    ('GK', 'Goalkeeper'),
    ('CB', 'Defender'),
    ('LB', 'Defender'),
    ('RB', 'Defender'),
    ('LWB', 'Defender'),
    ('RWB', 'Defender'),
    ('DM', 'Midfielder'),
    ('CM', 'Midfielder'),
    ('AM', 'Midfielder'),
    ('LM', 'Midfielder'),
    ('RM', 'Midfielder'),
    ('LW', 'Forward'),
    ('RW', 'Forward'),
    ('ST', 'Forward'),
    ('CF', 'Forward');

-- Player Positions (Many-to-Many)
CREATE TABLE player_positions (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    position_id SMALLINT NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT uq_player_position UNIQUE (player_id, position_id)
);

CREATE INDEX idx_player_positions_player ON player_positions(player_id);
CREATE INDEX idx_player_positions_position ON player_positions(position_id);
CREATE INDEX idx_player_positions_primary ON player_positions(is_primary) WHERE is_primary = TRUE;

-- ==============================================
-- STATISTICS TABLES
-- ==============================================

-- Player Matchday Stats (Granular Data)
CREATE TABLE player_matchday_stats (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    matchday_id BIGINT NOT NULL REFERENCES matchdays(id) ON DELETE CASCADE,
    team_id BIGINT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    opponent_team_id BIGINT REFERENCES teams(id) ON DELETE SET NULL,
    
    -- Match Info
    started BOOLEAN DEFAULT FALSE,
    minutes_played SMALLINT DEFAULT 0 CHECK (minutes_played >= 0 AND minutes_played <= 120),
    
    -- Basic Stats
    goals SMALLINT DEFAULT 0 CHECK (goals >= 0),
    assists SMALLINT DEFAULT 0 CHECK (assists >= 0),
    yellow_cards SMALLINT DEFAULT 0 CHECK (yellow_cards >= 0),
    red_cards SMALLINT DEFAULT 0 CHECK (red_cards >= 0 AND red_cards <= 1),
    
    -- Passing (Advanced)
    progressive_passes SMALLINT CHECK (progressive_passes IS NULL OR progressive_passes >= 0),
    progressive_carries SMALLINT CHECK (progressive_carries IS NULL OR progressive_carries >= 0),
    progressive_pass_distance_meters SMALLINT CHECK (progressive_pass_distance_meters IS NULL OR progressive_pass_distance_meters >= 0),
    passes_completed SMALLINT CHECK (passes_completed IS NULL OR passes_completed >= 0),
    passes_attempted SMALLINT CHECK (passes_attempted IS NULL OR passes_attempted >= 0),
    pass_completion_pct DECIMAL(5,2) CHECK (pass_completion_pct IS NULL OR (pass_completion_pct >= 0 AND pass_completion_pct <= 100)),
    short_passes_completed SMALLINT CHECK (short_passes_completed IS NULL OR short_passes_completed >= 0),
    medium_passes_completed SMALLINT CHECK (medium_passes_completed IS NULL OR medium_passes_completed >= 0),
    long_passes_completed SMALLINT CHECK (long_passes_completed IS NULL OR long_passes_completed >= 0),
    key_passes SMALLINT CHECK (key_passes IS NULL OR key_passes >= 0),
    passes_into_final_third SMALLINT CHECK (passes_into_final_third IS NULL OR passes_into_final_third >= 0),
    passes_into_penalty_area SMALLINT CHECK (passes_into_penalty_area IS NULL OR passes_into_penalty_area >= 0),
    crosses_into_penalty_area SMALLINT CHECK (crosses_into_penalty_area IS NULL OR crosses_into_penalty_area >= 0),
    
    -- Shooting
    shots_total SMALLINT CHECK (shots_total IS NULL OR shots_total >= 0),
    shots_on_target SMALLINT CHECK (shots_on_target IS NULL OR shots_on_target >= 0),
    xg DECIMAL(4,2) CHECK (xg IS NULL OR xg >= 0),
    npxg DECIMAL(4,2) CHECK (npxg IS NULL OR npxg >= 0),
    xa DECIMAL(4,2) CHECK (xa IS NULL OR xa >= 0),
    
    -- Defensive
    pressures SMALLINT CHECK (pressures IS NULL OR pressures >= 0),
    successful_pressures SMALLINT CHECK (successful_pressures IS NULL OR successful_pressures >= 0),
    pressure_success_pct DECIMAL(5,2) CHECK (pressure_success_pct IS NULL OR (pressure_success_pct >= 0 AND pressure_success_pct <= 100)),
    tackles SMALLINT CHECK (tackles IS NULL OR tackles >= 0),
    tackles_won SMALLINT CHECK (tackles_won IS NULL OR tackles_won >= 0),
    interceptions SMALLINT CHECK (interceptions IS NULL OR interceptions >= 0),
    blocks SMALLINT CHECK (blocks IS NULL OR blocks >= 0),
    clearances SMALLINT CHECK (clearances IS NULL OR clearances >= 0),
    aerials_won SMALLINT CHECK (aerials_won IS NULL OR aerials_won >= 0),
    aerials_lost SMALLINT CHECK (aerials_lost IS NULL OR aerials_lost >= 0),
    
    -- Dribbling
    dribbles_attempted SMALLINT CHECK (dribbles_attempted IS NULL OR dribbles_attempted >= 0),
    dribbles_completed SMALLINT CHECK (dribbles_completed IS NULL OR dribbles_completed >= 0),
    dribble_success_pct DECIMAL(5,2) CHECK (dribble_success_pct IS NULL OR (dribble_success_pct >= 0 AND dribble_success_pct <= 100)),
    
    -- Possession
    touches SMALLINT CHECK (touches IS NULL OR touches >= 0),
    touches_defensive_pen_area SMALLINT CHECK (touches_defensive_pen_area IS NULL OR touches_defensive_pen_area >= 0),
    touches_attacking_pen_area SMALLINT CHECK (touches_attacking_pen_area IS NULL OR touches_attacking_pen_area >= 0),
    miscontrols SMALLINT CHECK (miscontrols IS NULL OR miscontrols >= 0),
    dispossessed SMALLINT CHECK (dispossessed IS NULL OR dispossessed >= 0),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_player_matchday UNIQUE (player_id, matchday_id)
);

CREATE INDEX idx_pms_player ON player_matchday_stats(player_id);
CREATE INDEX idx_pms_matchday ON player_matchday_stats(matchday_id);
CREATE INDEX idx_pms_team ON player_matchday_stats(team_id);
CREATE INDEX idx_pms_opponent ON player_matchday_stats(opponent_team_id);
CREATE INDEX idx_pms_minutes ON player_matchday_stats(minutes_played);

-- Player Season Stats (Aggregated for Performance)
CREATE TABLE player_season_stats (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    season_id BIGINT NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    league_id BIGINT NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    team_id BIGINT REFERENCES teams(id) ON DELETE SET NULL,
    
    -- Aggregated Basic Stats
    matches_played SMALLINT DEFAULT 0 CHECK (matches_played >= 0),
    matches_started SMALLINT DEFAULT 0 CHECK (matches_started >= 0),
    minutes_played INTEGER DEFAULT 0 CHECK (minutes_played >= 0),
    goals SMALLINT DEFAULT 0 CHECK (goals >= 0),
    assists SMALLINT DEFAULT 0 CHECK (assists >= 0),
    yellow_cards SMALLINT DEFAULT 0 CHECK (yellow_cards >= 0),
    red_cards SMALLINT DEFAULT 0 CHECK (red_cards >= 0),
    
    -- Per 90 Stats
    progressive_passes_per90 DECIMAL(5,2) CHECK (progressive_passes_per90 IS NULL OR progressive_passes_per90 >= 0),
    progressive_carries_per90 DECIMAL(5,2) CHECK (progressive_carries_per90 IS NULL OR progressive_carries_per90 >= 0),
    passes_completed_per90 DECIMAL(5,2) CHECK (passes_completed_per90 IS NULL OR passes_completed_per90 >= 0),
    pass_completion_pct DECIMAL(5,2) CHECK (pass_completion_pct IS NULL OR (pass_completion_pct >= 0 AND pass_completion_pct <= 100)),
    key_passes_per90 DECIMAL(5,2) CHECK (key_passes_per90 IS NULL OR key_passes_per90 >= 0),
    
    xg_total DECIMAL(5,2) CHECK (xg_total IS NULL OR xg_total >= 0),
    xg_per90 DECIMAL(5,2) CHECK (xg_per90 IS NULL OR xg_per90 >= 0),
    xa_total DECIMAL(5,2) CHECK (xa_total IS NULL OR xa_total >= 0),
    xa_per90 DECIMAL(5,2) CHECK (xa_per90 IS NULL OR xa_per90 >= 0),
    
    pressures_per90 DECIMAL(5,2) CHECK (pressures_per90 IS NULL OR pressures_per90 >= 0),
    successful_pressures_per90 DECIMAL(5,2) CHECK (successful_pressures_per90 IS NULL OR successful_pressures_per90 >= 0),
    pressure_success_pct DECIMAL(5,2) CHECK (pressure_success_pct IS NULL OR (pressure_success_pct >= 0 AND pressure_success_pct <= 100)),
    tackles_per90 DECIMAL(5,2) CHECK (tackles_per90 IS NULL OR tackles_per90 >= 0),
    interceptions_per90 DECIMAL(5,2) CHECK (interceptions_per90 IS NULL OR interceptions_per90 >= 0),
    
    dribbles_completed_per90 DECIMAL(5,2) CHECK (dribbles_completed_per90 IS NULL OR dribbles_completed_per90 >= 0),
    dribble_success_pct DECIMAL(5,2) CHECK (dribble_success_pct IS NULL OR (dribble_success_pct >= 0 AND dribble_success_pct <= 100)),
    
    -- Calculated Fields
    goals_plus_assists SMALLINT DEFAULT 0 CHECK (goals_plus_assists >= 0),
    npxg_plus_xa DECIMAL(5,2) CHECK (npxg_plus_xa IS NULL OR npxg_plus_xa >= 0),
    
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_player_season_league UNIQUE (player_id, season_id, league_id),
    CONSTRAINT chk_matches_started CHECK (matches_started <= matches_played)
);

CREATE INDEX idx_pss_player ON player_season_stats(player_id);
CREATE INDEX idx_pss_season ON player_season_stats(season_id);
CREATE INDEX idx_pss_league ON player_season_stats(league_id);
CREATE INDEX idx_pss_team ON player_season_stats(team_id);
CREATE INDEX idx_pss_minutes ON player_season_stats(minutes_played);
CREATE INDEX idx_pss_goals_assists ON player_season_stats(goals_plus_assists);

-- Market Value History
CREATE TABLE market_value_history (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    value_date DATE NOT NULL,
    market_value_eur INTEGER NOT NULL CHECK (market_value_eur >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_player_value_date UNIQUE (player_id, value_date)
);

CREATE INDEX idx_mvh_player ON market_value_history(player_id);
CREATE INDEX idx_mvh_date ON market_value_history(value_date);
CREATE INDEX idx_mvh_player_date ON market_value_history(player_id, value_date DESC);

-- ==============================================
-- USER & APPLICATION TABLES
-- ==============================================

-- Users
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Watchlists
CREATE TABLE watchlists (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_watchlist_name_length CHECK (LENGTH(name) >= 2)
);

CREATE INDEX idx_watchlists_user ON watchlists(user_id);
CREATE INDEX idx_watchlists_public ON watchlists(is_public) WHERE is_public = TRUE;

-- Watchlist Players (Many-to-Many)
CREATE TABLE watchlist_players (
    id BIGSERIAL PRIMARY KEY,
    watchlist_id BIGINT NOT NULL REFERENCES watchlists(id) ON DELETE CASCADE,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    notes TEXT,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_watchlist_player UNIQUE (watchlist_id, player_id)
);

CREATE INDEX idx_wp_watchlist ON watchlist_players(watchlist_id);
CREATE INDEX idx_wp_player ON watchlist_players(player_id);

-- Player Comparisons
CREATE TABLE player_comparisons (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    player_ids BIGINT[] NOT NULL,
    season_id BIGINT REFERENCES seasons(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_comparison_name_length CHECK (LENGTH(name) >= 2),
    CONSTRAINT chk_player_ids_count CHECK (array_length(player_ids, 1) >= 2 AND array_length(player_ids, 1) <= 6)
);

CREATE INDEX idx_comparisons_user ON player_comparisons(user_id);
CREATE INDEX idx_comparisons_season ON player_comparisons(season_id);

-- ==============================================
-- TRIGGERS & FUNCTIONS
-- ==============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_watchlists_updated_at BEFORE UPDATE ON watchlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_matchday_stats_updated_at BEFORE UPDATE ON player_matchday_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================
-- VIEWS FOR COMMON QUERIES
-- ==============================================

-- View: Current Season Players with Basic Info
CREATE OR REPLACE VIEW v_current_players AS
SELECT 
    p.id,
    p.full_name,
    p.date_of_birth,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS age,
    p.nationality,
    p.height_cm,
    p.foot,
    t.name AS current_team,
    l.name AS current_league,
    p.current_market_value_eur,
    p.contract_expires,
    STRING_AGG(DISTINCT pos.name, ', ' ORDER BY pos.name) AS positions
FROM players p
LEFT JOIN teams t ON p.current_team_id = t.id
LEFT JOIN leagues l ON t.league_id = l.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
GROUP BY p.id, p.full_name, p.date_of_birth, p.nationality, p.height_cm, 
         p.foot, t.name, l.name, p.current_market_value_eur, p.contract_expires;

-- Comments for documentation
COMMENT ON TABLE players IS 'Core player information and profiles';
COMMENT ON TABLE player_matchday_stats IS 'Detailed per-matchday statistics for granular analysis';
COMMENT ON TABLE player_season_stats IS 'Aggregated seasonal statistics for performance optimization';
COMMENT ON TABLE leagues IS 'Football leagues with coverage metadata';
COMMENT ON TABLE teams IS 'Football clubs and teams';
COMMENT ON COLUMN leagues.has_advanced_stats IS 'Indicates if league has FBref coverage with advanced metrics';
COMMENT ON COLUMN player_season_stats.last_updated IS 'Timestamp of last aggregation calculation';