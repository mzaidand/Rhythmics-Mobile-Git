package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.TokenResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.DtoToWebMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.AuthService;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.GoogleAuthService;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("api/auth/google")
public class GoogleAuthController {

    private static final Logger log = LoggerFactory.getLogger(GoogleAuthController.class);

    @Autowired
    private GoogleAuthService googleAuthService;

    @Autowired
    private AuthService authService;

    @GetMapping("/login")
    public void initiateGoogleLogin(HttpServletResponse response) throws IOException {
        String authUrl = googleAuthService.generateAuthUrl();
        log.info("Auth url: " + authUrl);
        response.sendRedirect(authUrl);
    }

    @GetMapping("/callback")
    public WebResponse<TokenResponse> handleGoogleCallback(HttpServletResponse response, @RequestParam("code") String code) throws IOException {
        String accessToken = googleAuthService.getAccessToken(code);
        Map<String, Object> profile = googleAuthService.getUserProfile(accessToken);
        TokenResponse tokenResponse = googleAuthService.findOrCreateUser(profile, accessToken);
        log.info("User: {}", profile);
        log.info("Token: {}", accessToken);
        log.info("TokenResponse: {}", tokenResponse.getToken());

        String redirectUrl = "http://localhost:5173/sign-in?token=" + tokenResponse.getToken()
                + "&expired_at=" + tokenResponse.getExpiredAt();
        response.sendRedirect(redirectUrl);

        return DtoToWebMapper.toWebResponse(tokenResponse);
    }
}