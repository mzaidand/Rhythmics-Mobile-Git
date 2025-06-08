package rhythmics.rhythmics_music_studio_booking_website_backend.dto.room;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.photo.PhotoUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.roomchedule.RoomScheduleUpdateRequest;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RoomUpdateRequest {

    private Long price;

    private String type;

    private List<PhotoUpdateRequest> gallery;

    private List<RoomScheduleUpdateRequest> roomSchedules;

    private List<String> removedImages;
}
