package rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings;


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

public class BookingAddRequest {

    @NotBlank
    private LocalDate date;

    @NotBlank
    @JsonProperty("time_slot")
    private String timeSlot;

    @NotBlank
    @JsonProperty("room_name")
    private String roomName;

    @NotBlank
    @JsonProperty
    private String price;

}
