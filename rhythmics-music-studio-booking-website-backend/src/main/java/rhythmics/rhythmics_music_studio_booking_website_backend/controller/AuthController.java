package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.DtoToWebMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.AuthService;

@RestController
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping(
            path = "/api/auth/login",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<TokenResponse> login(@RequestBody UserLoginRequest request) {
        TokenResponse tokenResponse = authService.login(request);
        return DtoToWebMapper.toWebResponse(tokenResponse);
    }

    @PostMapping(
            path = "/api/auth/forgot-password",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> forgotPassword(@RequestBody UserForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return DtoToWebMapper.toWebResponse("OTP sent to your email");
    }

    @PostMapping(
            path = "/api/auth/validate-otp",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<TokenResponse> validateOtp(@RequestBody UserValidateOtpRequest request) {
        TokenResponse tokenResponse = authService.validateOtp(request);
        return DtoToWebMapper.toWebResponse(tokenResponse);
    }

    @PatchMapping(
            path = "/api/auth/reset-password",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> resetPassword(@RequestBody UserResetPasswordRequest request, User user) {
        authService.resetPassword(request, user);
        return DtoToWebMapper.toWebResponse("Password has been reset successfully");
    }

    @DeleteMapping(value = "/api/auth/logout", produces = MediaType.APPLICATION_JSON_VALUE)
    public WebResponse<String> logout(@RequestHeader("Authorization") String accessToken) {
        authService.logout(accessToken);
        return DtoToWebMapper.toWebResponse("Successfully logged out");
    }
}
