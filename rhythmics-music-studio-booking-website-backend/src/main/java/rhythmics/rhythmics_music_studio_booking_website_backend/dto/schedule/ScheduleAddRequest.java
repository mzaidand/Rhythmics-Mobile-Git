package rhythmics.rhythmics_music_studio_booking_website_backend.dto.schedule;


import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder

public class ScheduleAddRequest {

    @NotBlank
    private LocalDate date;

    @NotBlank
    @JsonProperty("time_slot")
    private String timeSlot;
}
