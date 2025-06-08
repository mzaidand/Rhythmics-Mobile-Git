package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.DtoToWebMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.StudioService;

import java.util.List;

@RestController
public class StudioController {

    @Autowired
    private StudioService studioService;

    @PostMapping(
            path = "/api/studios",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<StudioDataResponse> create(User user, @RequestBody StudioAddRequest request) {
        StudioDataResponse studioDataResponse = studioService.create(user, request);
        return DtoToWebMapper.toWebResponse(studioDataResponse);
    }

    @GetMapping(
            path = "/api/studios/{studioId}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<StudioDataResponse> get(@PathVariable("studioId") Long studioId) {
        StudioDataResponse studioDataResponse = studioService.get(studioId);
        return DtoToWebMapper.toWebResponse(studioDataResponse);
    }

    @PatchMapping(
            path = "/api/studios/{studioId}",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<StudioDataResponse> update(User user, @PathVariable("studioId") Long studioId, @RequestBody StudioUpdateRequest request) {
        StudioDataResponse studioDataResponse = studioService.update(user, studioId, request);
        return DtoToWebMapper.toWebResponse(studioDataResponse);
    }

    @DeleteMapping(
            path = "/api/studios/{studioId}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> delete(User user, @PathVariable("studioId") Long studioId) {
        studioService.delete(user, studioId);
        return DtoToWebMapper.toWebResponse("Successfully deleted studio");
    }

    @GetMapping(
            path = "/api/studios",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<StudioDataResponse>> getAll() {
        List<StudioDataResponse> studioDataResponses = studioService.getAll();
        return DtoToWebMapper.toWebResponse(studioDataResponses);
    }

    @GetMapping(
            path = "/api/studios/owner",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<StudioDataResponse>> getAllFromOwner(User user) {
        List<StudioDataResponse> studioDataResponses = studioService.getAllFromOwner(user);
        return DtoToWebMapper.toWebResponse(studioDataResponses);
    }

    @PatchMapping(
            path = "/api/studios/{studioId}/rating",
            consumes = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> updateRating(@PathVariable("studioId") Long studioId, @RequestBody double rating) {
        studioService.updateRating(studioId, rating);
        return DtoToWebMapper.toWebResponse("Successfully updated rating");
    }

    @DeleteMapping(
            path = "/api/studios/{studioId}/delete",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> deleteReview(@PathVariable("studioId") Long studioId) {
        studioService.deleteStudioAdmin(studioId);
        return DtoToWebMapper.toWebResponse("Successfully deleted studio review");
    }

    @PatchMapping(
            path = "/api/studios/{studioId}/update",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<StudioDataResponse> updateAdmin(User user, @PathVariable("studioId") Long studioId, @RequestBody StudioUpdateRequest request) {
        StudioDataResponse studioDataResponse = studioService.updateAdmin(studioId, request);
        return DtoToWebMapper.toWebResponse(studioDataResponse);
    }
}
