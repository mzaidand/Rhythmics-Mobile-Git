package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.server.ResponseStatusException;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;

@RestControllerAdvice
public class ErrorController {

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<WebResponse<String>> constraintViolationException(ConstraintViolationException exception) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(WebResponse.<String>builder()
                        .code(HttpStatus.BAD_REQUEST.value())
                        .status("Bad Request")
                        .errors(exception.getMessage())
                        .build());
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<WebResponse<String>> apiException(ResponseStatusException exception) {
        return ResponseEntity.status(exception.getStatusCode())
                .body(WebResponse.<String>builder()
                        .code(exception.getStatusCode().value())
                        .status(((HttpStatus) exception.getStatusCode()).getReasonPhrase())
                        .errors(exception.getReason())
                        .data(null)
                        .build());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<WebResponse<String>> handleMaxUploadSizeExceededException(MaxUploadSizeExceededException exception) {
        return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                .body(WebResponse.<String>builder()
                        .code(HttpStatus.PAYLOAD_TOO_LARGE.value())
                        .status("Payload Too Large")
                        .errors("File size exceeds the maximum upload limit.")
                        .build());
    }
}
