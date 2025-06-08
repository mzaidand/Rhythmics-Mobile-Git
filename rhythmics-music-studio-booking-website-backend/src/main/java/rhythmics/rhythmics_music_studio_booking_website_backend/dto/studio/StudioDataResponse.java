package rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomDataResponse;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class StudioDataResponse {

    private Long id;

    private String name;

    @JsonProperty("phone_number")
    private String phoneNumber;

    private String street;

    private String district;

    @JsonProperty("city_or_regency")
    private String cityOrRegency;

    private String province;

    @JsonProperty("postal_code")
    private String postalCode;

    private Double latitude;

    private Double longitude;

    private Double rating;

    @JsonProperty("reviews_count")
    private Integer reviewsCount;

    @JsonProperty("owner_id")
    private Long ownerId;

    private List<RoomDataResponse> rooms;
}
