package rhythmics.rhythmics_music_studio_booking_website_backend.dto.roomchedule;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.schedule.ScheduleDataResponse;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RoomScheduleDataResponse {

    private Long id;

    private String status;

    @JsonProperty("room_id")
    private Long roomId;

    @JsonProperty("schedule")
    private ScheduleDataResponse schedule;

}
