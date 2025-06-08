package rhythmics.rhythmics_music_studio_booking_website_backend.helper;

import org.springframework.http.HttpStatus;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;

public class DtoToWebMapper {
    public static <T> WebResponse<T> toWebResponse(T data) {
        return WebResponse.<T>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data(data)
                .build();
    }
}
