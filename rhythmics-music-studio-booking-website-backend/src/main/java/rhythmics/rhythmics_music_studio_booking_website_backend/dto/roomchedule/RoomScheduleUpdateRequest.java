package rhythmics.rhythmics_music_studio_booking_website_backend.dto.roomchedule;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RoomScheduleUpdateRequest {

    private String status;

}
