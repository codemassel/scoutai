// ScoutAI Database Schema - 3. Normalform
// Check https://dbdiagram.io/ or the file database-schema.png to visualize!

Table players {
  id bigserial [pk, increment]
  transfermarkt_id varchar(50) [unique, not null]
  fbref_id varchar(50) [unique] // FBref Player ID
  full_name varchar(255) [not null]
  date_of_birth date [not null]
  nationality varchar(100)
  height_cm smallint
  foot varchar(10) // left, right, both
  current_team_id bigint [ref: > teams.id]
  current_market_value_eur integer
  contract_expires date
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
  
  indexes {
    full_name
    date_of_birth
    nationality
    fbref_id
  }
}

Table teams {
  id bigserial [pk, increment]
  name varchar(255) [not null]
  league_id bigint [ref: > leagues.id]
  country varchar(100)
  stadium varchar(255)
  created_at timestamp [default: `now()`]
  
  indexes {
    name
    league_id
  }
}

Table leagues {
  id bigserial [pk, increment]
  name varchar(255) [not null, unique]
  country varchar(100) [not null]
  tier smallint // 1 = Top League, 2 = Second Division, etc.
  has_advanced_stats boolean [default: false] // FBref Coverage Flag
  fbref_id varchar(50) [unique] // FBref League ID
  created_at timestamp [default: `now()`]
  
  indexes {
    country
    tier
    fbref_id
  }
}

Table seasons {
  id bigserial [pk, increment]
  name varchar(20) [not null, unique] // e.g. "2024/25"
  start_year smallint [not null]
  end_year smallint [not null]
  
  indexes {
    start_year
  }
}

Table matchdays {
  id bigserial [pk, increment]
  league_id bigint [ref: > leagues.id, not null]
  season_id bigint [ref: > seasons.id, not null]
  matchday_number smallint [not null] // 1, 2, 3, ... 34
  date_start date [not null] // Start date of matchday
  date_end date // End date (for matchdays spanning multiple days)
  
  indexes {
    (league_id, season_id, matchday_number) [unique]
    league_id
    season_id
  }
}

// NEW: Matchday-Level Stats (Granular Data)
Table player_matchday_stats {
  id bigserial [pk, increment]
  player_id bigint [ref: > players.id, not null]
  matchday_id bigint [ref: > matchdays.id, not null]
  team_id bigint [ref: > teams.id, not null]
  opponent_team_id bigint [ref: > teams.id] // Opponent
  
  // Match Info
  started boolean [default: false] // Started vs. Substitute
  minutes_played smallint [default: 0]
  
  // Basic Stats
  goals smallint [default: 0]
  assists smallint [default: 0]
  yellow_cards smallint [default: 0]
  red_cards smallint [default: 0]
  
  // Advanced Stats (FBref) - nullable for leagues without data
  progressive_passes smallint
  progressive_carries smallint
  progressive_pass_distance_meters smallint
  passes_completed smallint
  passes_attempted smallint
  pass_completion_pct decimal(5,2)
  short_passes_completed smallint
  medium_passes_completed smallint
  long_passes_completed smallint
  key_passes smallint
  passes_into_final_third smallint
  passes_into_penalty_area smallint
  crosses_into_penalty_area smallint
  
  // Shooting
  shots_total smallint
  shots_on_target smallint
  xg decimal(4,2) // Expected Goals
  npxg decimal(4,2) // Non-Penalty xG
  xa decimal(4,2) // Expected Assists
  
  // Defensive
  pressures smallint
  successful_pressures smallint
  pressure_success_pct decimal(5,2)
  tackles smallint
  tackles_won smallint
  interceptions smallint
  blocks smallint
  clearances smallint
  aerials_won smallint
  aerials_lost smallint
  
  // Dribbling
  dribbles_attempted smallint
  dribbles_completed smallint
  dribble_success_pct decimal(5,2)
  
  // Possession
  touches smallint
  touches_defensive_pen_area smallint
  touches_attacking_pen_area smallint
  miscontrols smallint
  dispossessed smallint
  
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
  
  indexes {
    (player_id, matchday_id) [unique]
    player_id
    matchday_id
    team_id
  }
}

// Aggregated Season Stats (for performance)
Table player_season_stats {
  id bigserial [pk, increment]
  player_id bigint [ref: > players.id, not null]
  season_id bigint [ref: > seasons.id, not null]
  league_id bigint [ref: > leagues.id, not null]
  team_id bigint [ref: > teams.id]
  
  // Aggregated Stats (SUM/AVG from matchday stats)
  matches_played smallint [default: 0]
  matches_started smallint [default: 0]
  minutes_played integer [default: 0]
  goals smallint [default: 0]
  assists smallint [default: 0]
  yellow_cards smallint [default: 0]
  red_cards smallint [default: 0]
  
  // Aggregated Advanced Stats (AVG per 90 mins)
  progressive_passes_per90 decimal(5,2)
  progressive_carries_per90 decimal(5,2)
  passes_completed_per90 decimal(5,2)
  pass_completion_pct decimal(5,2)
  key_passes_per90 decimal(5,2)
  
  xg_total decimal(5,2)
  xg_per90 decimal(5,2)
  xa_total decimal(5,2)
  xa_per90 decimal(5,2)
  
  pressures_per90 decimal(5,2)
  successful_pressures_per90 decimal(5,2)
  pressure_success_pct decimal(5,2)
  tackles_per90 decimal(5,2)
  interceptions_per90 decimal(5,2)
  
  dribbles_completed_per90 decimal(5,2)
  dribble_success_pct decimal(5,2)
  
  // Calculated fields
  goals_plus_assists smallint [default: 0]
  npxg_plus_xa decimal(5,2)
  
  last_updated timestamp [default: `now()`]
  
  indexes {
    (player_id, season_id, league_id) [unique]
    player_id
    season_id
    league_id
  }
}

Table positions {
  id smallserial [pk, increment]
  name varchar(50) [not null, unique] // GK, CB, LB, RB, DM, CM, AM, LW, RW, ST
  position_group varchar(20) [not null] // Goalkeeper, Defender, Midfielder, Forward
}

// Many-to-Many: Player can play multiple positions
Table player_positions {
  id bigserial [pk, increment]
  player_id bigint [ref: > players.id, not null]
  position_id smallint [ref: > positions.id, not null]
  is_primary boolean [default: false] // Main position
  
  indexes {
    (player_id, position_id) [unique]
    player_id
    position_id
  }
}

// Market Value History (Time Series)
Table market_value_history {
  id bigserial [pk, increment]
  player_id bigint [ref: > players.id, not null]
  value_date date [not null]
  market_value_eur integer [not null]
  created_at timestamp [default: `now()`]
  
  indexes {
    (player_id, value_date) [unique]
    player_id
    value_date
  }
}

// User Management
Table users {
  id bigserial [pk, increment]
  email varchar(255) [unique, not null]
  password_hash varchar(255) [not null] // BCrypt
  username varchar(100) [unique, not null]
  is_active boolean [default: true]
  created_at timestamp [default: `now()`]
  last_login timestamp
  
  indexes {
    email
    username
  }
}

Table watchlists {
  id bigserial [pk, increment]
  user_id bigint [ref: > users.id, not null]
  name varchar(255) [not null]
  description text
  is_public boolean [default: false]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
  
  indexes {
    user_id
  }
}

// Junction Table for Watchlist-Players (Many-to-Many)
Table watchlist_players {
  id bigserial [pk, increment]
  watchlist_id bigint [ref: > watchlists.id, not null]
  player_id bigint [ref: > players.id, not null]
  notes text // User notes about player
  added_at timestamp [default: `now()`]
  
  indexes {
    (watchlist_id, player_id) [unique]
    watchlist_id
    player_id
  }
}

// Saved Player Comparisons
Table player_comparisons {
  id bigserial [pk, increment]
  user_id bigint [ref: > users.id, not null]
  name varchar(255) [not null]
  player_ids bigint[] [not null] // Array of player IDs (max 4-6)
  season_id bigint [ref: > seasons.id] // Compare specific season
  created_at timestamp [default: `now()`]
  
  indexes {
    user_id
  }
}