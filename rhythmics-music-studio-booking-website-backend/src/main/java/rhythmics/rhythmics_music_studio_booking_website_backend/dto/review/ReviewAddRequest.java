package rhythmics.rhythmics_music_studio_booking_website_backend.dto.review;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewAddRequest {

    @NotNull
    private Integer rating;

    @NotBlank
    private String comment;

}
