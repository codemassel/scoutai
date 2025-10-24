package com.scoutai.backend.domain.season;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

/**
 * Season entity representing football seasons (e.g., "2024/25").
 */
@Entity
@Table(name = "seasons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Season {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 20)
    @NotBlank(message = "Season name is required")
    private String name;

    @Column(name = "start_year", nullable = false)
    @NotNull(message = "Start year is required")
    private Short startYear;

    @Column(name = "end_year", nullable = false)
    @NotNull(message = "End year is required")
    private Short endYear;
}