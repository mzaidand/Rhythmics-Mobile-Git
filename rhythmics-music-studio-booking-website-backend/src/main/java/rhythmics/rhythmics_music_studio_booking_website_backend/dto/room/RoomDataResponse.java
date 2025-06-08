package rhythmics.rhythmics_music_studio_booking_website_backend.dto.room;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.photo.PhotoDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.roomchedule.RoomScheduleDataResponse;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RoomDataResponse {

    private Long id;

    private Long price;

    private String type;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    @JsonProperty("studio_id")
    private Long studioId;

    private List<ReviewDataResponse> reviews;

    private List<PhotoDataResponse> gallery;

    private List<RoomScheduleDataResponse> roomSchedules;

}
