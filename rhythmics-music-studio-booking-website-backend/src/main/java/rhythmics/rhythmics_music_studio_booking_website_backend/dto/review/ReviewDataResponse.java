package rhythmics.rhythmics_music_studio_booking_website_backend.dto.review;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.UserDataResponse;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewDataResponse {

    private Long id;

    private Integer rating;

    private String comment;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    @JsonProperty("room_id")
    private Long roomId;

    private UserDataResponse user;
}
