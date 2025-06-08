package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.DtoToWebMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.RoomService;

import java.util.List;

@RestController
public class RoomController {

    @Autowired
    private RoomService roomService;

    @PostMapping(
            path = "/api/studios/{studioId}/rooms",
            consumes = {MediaType.MULTIPART_FORM_DATA_VALUE, MediaType.APPLICATION_JSON_VALUE},
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<RoomDataResponse> add(
            User user,
            @PathVariable("studioId") Long studioId,
            @RequestPart("room") RoomAddRequest request,
            @RequestPart("files") List<MultipartFile> files
    ) {
        RoomDataResponse roomDataResponse = roomService.add(user, request, files, studioId);
        return DtoToWebMapper.toWebResponse(roomDataResponse);
    }

    @GetMapping(
            path = "/api/studios/{studioId}/rooms/{roomId}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<RoomDataResponse> get(User user, @PathVariable("studioId") Long studioId, @PathVariable("roomId") Long roomId) {
        RoomDataResponse roomDataResponse = roomService.get(user, studioId, roomId);
        return DtoToWebMapper.toWebResponse(roomDataResponse);
    }

    @GetMapping(
            path = "/api/studios/{studioId}/rooms",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<RoomDataResponse>> get(User user, @PathVariable("studioId") Long studioId) {
        List<RoomDataResponse> roomDataResponses = roomService.getAll(user, studioId);
        return DtoToWebMapper.toWebResponse(roomDataResponses);
    }

    @PatchMapping(
            path = "/api/studios/{studioId}/rooms/{roomId}",
            consumes = {MediaType.MULTIPART_FORM_DATA_VALUE, MediaType.APPLICATION_JSON_VALUE}
    )
    public WebResponse<RoomDataResponse> update(
            User user,
            @PathVariable("studioId") Long studioId,
            @PathVariable("roomId") Long roomId,
            @RequestPart("room") RoomUpdateRequest request,
            @RequestPart(value = "files", required = false) List<MultipartFile> files
    ) {
        RoomDataResponse roomDataResponse = roomService.update(user, request, files, studioId, roomId);
        return DtoToWebMapper.toWebResponse(roomDataResponse);
    }

    @DeleteMapping(
            path = "/api/studios/{studioId}/rooms/{roomId}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> delete(User user, @PathVariable("studioId") Long studioId, @PathVariable("roomId") Long roomId) {
        roomService.delete(user, studioId, roomId);
        return DtoToWebMapper.toWebResponse("Successfully deleted room");
    }

    @GetMapping(
            path = "/api/rooms",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<RoomDataResponse>> getAllRooms() {
        List<RoomDataResponse> roomDataResponses = roomService.getAllRoom();
        return DtoToWebMapper.toWebResponse(roomDataResponses);
    }
}
