package com.scoutai.backend.domain.stats;

import com.scoutai.backend.domain.player.Player;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "player_season_stats")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlayerSeasonStats {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;
    
    @Column(name = "season_id")
    private Long seasonId;
    
    @Column(name = "league_id")
    private Long leagueId;
}