package rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class StudioUpdateRequest {

    @Size(max = 100)
    private String name;

    @Pattern(regexp = "\\+?[0-9]*")
    @Size(max = 100)
    @JsonProperty("phone_number")
    private String phoneNumber;

    @Size(max = 255)
    private String street;

    @Size(max = 100)
    private String district;

    @Size(max = 100)
    @JsonProperty("city_or_regency")
    private String cityOrRegency;

    @Size(max = 100)
    private String province;

    @Size(max = 10)
    @JsonProperty("postal_code")
    private String postalCode;

    @DecimalMin(value = "-90.0")
    @DecimalMax(value = "90.0")
    private Double latitude;

    @DecimalMin(value = "-180.0")
    @DecimalMax(value = "180.0")
    private Double longitude;

}
