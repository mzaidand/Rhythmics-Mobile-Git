package rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BookingUpdateStatusRequest {

    private String status;
}
