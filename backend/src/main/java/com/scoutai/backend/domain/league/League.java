package com.scoutai.backend.domain.league;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * League entity representing football leagues.
 */
@Entity
@Table(name = "leagues")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class League {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    @NotBlank(message = "League name is required")
    private String name;

    @Column(nullable = false, length = 100)
    @NotBlank(message = "Country is required")
    private String country;

    @Column(nullable = false)
    @NotNull(message = "Tier is required")
    private Short tier;

    @Column(name = "has_advanced_stats", nullable = false)
    @Builder.Default 
    private Boolean hasAdvancedStats = false;

    @Column(name = "fbref_id", unique = true, length = 50)
    private String fbrefId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}