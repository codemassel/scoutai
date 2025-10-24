package com.scoutai.backend.domain.player;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

/**
 * Position entity representing football positions (GK, CB, ST, etc.).
 * Maps to the 'positions' table in the database.
 * 
 * @author ScoutAI Team
 * @version 1.0
 */
@Entity
@Table(name = "positions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = "players")
@EqualsAndHashCode(of = {"id"})
public class Position {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Short id;

    @Column(nullable = false, unique = true, length = 50)
    @NotBlank(message = "Position name is required")
    private String name;

    @Column(name = "position_group", nullable = false, length = 20)
    @NotBlank(message = "Position group is required")
    @Pattern(regexp = "Goalkeeper|Defender|Midfielder|Forward", 
             message = "Position group must be Goalkeeper, Defender, Midfielder, or Forward")
    private String positionGroup;

    @ManyToMany(mappedBy = "positions")
    @Builder.Default
    private Set<Player> players = new HashSet<>();

    /**
     * Enum for standard position groups.
     */
    public enum PositionGroup {
        GOALKEEPER("Goalkeeper"),
        DEFENDER("Defender"),
        MIDFIELDER("Midfielder"),
        FORWARD("Forward");

        private final String displayName;

        PositionGroup(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }
}