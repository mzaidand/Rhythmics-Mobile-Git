package rhythmics.rhythmics_music_studio_booking_website_backend.dto.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import rhythmics.rhythmics_music_studio_booking_website_backend.validation.PasswordMatches;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@PasswordMatches
public class UserRegisterRequest {

    @NotBlank
    @Size(max = 100)
    private String email;

    @NotBlank
    @Size(max = 100)
    @JsonProperty("first_name")
    private String firstName;

    @Size(max = 100)
    @JsonProperty("last_name")
    private String lastName;

    @NotBlank
    @Size(min = 8, max = 100)
    private String password;

    @NotBlank
    @Size(min = 8, max = 100)
    @JsonProperty("confirmation_password")
    private String confirmationPassword;
}

