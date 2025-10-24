package com.scoutai.backend.domain.player;

import com.scoutai.backend.domain.stats.PlayerMatchdayStats;
import com.scoutai.backend.domain.stats.PlayerSeasonStats;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

/**
 * Player entity representing football players in the scouting system.
 * Maps to the 'players' table in the database.
 * 
 * @author ScoutAI Team
 * @version 1.0
 */
@Entity
@Table(name = "players", indexes = {
    @Index(name = "idx_players_full_name", columnList = "full_name"),
    @Index(name = "idx_players_dob", columnList = "date_of_birth"),
    @Index(name = "idx_players_nationality", columnList = "nationality")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = {"positions", "seasonStats", "matchdayStats"})
@EqualsAndHashCode(of = {"id"})
public class Player {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transfermarkt_id", unique = true, length = 50)
    private String transfermarktId;

    @Column(name = "fbref_id", unique = true, length = 50)
    private String fbrefId;

    @Column(name = "full_name", nullable = false)
    @NotBlank(message = "Player name is required")
    @Size(min = 2, max = 255, message = "Name must be between 2 and 255 characters")
    private String fullName;

    @Column(name = "date_of_birth", nullable = false)
    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    @Column(length = 100)
    private String nationality;

    @Column(name = "height_cm")
    @Min(value = 150, message = "Height must be at least 150cm")
    @Max(value = 220, message = "Height cannot exceed 220cm")
    private Short heightCm;

    @Column(length = 10)
    @Pattern(regexp = "left|right|both", message = "Foot must be 'left', 'right', or 'both'")
    private String foot;

    @Column(name = "current_team_id")
    private Long currentTeamId;

    @Column(name = "current_market_value_eur")
    @Min(value = 0, message = "Market value cannot be negative")
    private Integer currentMarketValueEur;

    @Column(name = "contract_expires")
    private LocalDate contractExpires;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // Relationships
    @ManyToMany
    @JoinTable(
        name = "player_positions",
        joinColumns = @JoinColumn(name = "player_id"),
        inverseJoinColumns = @JoinColumn(name = "position_id")
    )
    @Builder.Default
    private Set<Position> positions = new HashSet<>();

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlayerSeasonStats> seasonStats = new HashSet<>();

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlayerMatchdayStats> matchdayStats = new HashSet<>();

    // Business Methods
    
    /**
     * Calculates the player's current age based on date of birth.
     * @return age in years
     */
    public int getAge() {
        return LocalDate.now().getYear() - dateOfBirth.getYear();
    }

    /**
     * Checks if player has a valid contract.
     * @return true if contract is still valid, false otherwise
     */
    public boolean hasActiveContract() {
        return contractExpires != null && contractExpires.isAfter(LocalDate.now());
    }

    /**
     * Adds a position to the player's position set.
     * @param position the position to add
     */
    public void addPosition(Position position) {
        positions.add(position);
        position.getPlayers().add(this);
    }

    /**
     * Removes a position from the player's position set.
     * @param position the position to remove
     */
    public void removePosition(Position position) {
        positions.remove(position);
        position.getPlayers().remove(this);
    }
}