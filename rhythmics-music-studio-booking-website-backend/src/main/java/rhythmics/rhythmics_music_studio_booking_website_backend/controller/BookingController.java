package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingUpdateStatusRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.schedule.ScheduleDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.DtoToWebMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.BookingService;

import java.util.List;

@RestController
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @PostMapping(
            path = "/api/{studioId}/bookings",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<BookingDataResponse> create(User user, @PathVariable Long studioId, @RequestBody BookingAddRequest request) {
        BookingDataResponse bookingDataResponse = bookingService.create(user, studioId, request);
        return DtoToWebMapper.toWebResponse(bookingDataResponse);
    }

    @GetMapping(
            path = "/api/bookings",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<BookingDataResponse>> get(User user) {
        List<BookingDataResponse> bookings = bookingService.get(user);
        return DtoToWebMapper.toWebResponse(bookings);
    }

    @DeleteMapping(
            path = "/api/{bookingId}/bookings",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> delete(User user, @PathVariable Long bookingId) {
        bookingService.delete(user, bookingId);
        return DtoToWebMapper.toWebResponse("Delete Booking Successfully");
    }

    @PatchMapping(
            path = "/api/{bookingId}/bookings",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<BookingDataResponse> updateStatus(User user, @PathVariable Long bookingId, @RequestBody BookingUpdateStatusRequest request) {
        BookingDataResponse bookingDataResponse = bookingService.updateStatus(user, bookingId, request);
        return DtoToWebMapper.toWebResponse(bookingDataResponse);
    }

    @GetMapping(
            path = "/api/bookings/all",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<BookingDataResponse>> getAll() {
        List<BookingDataResponse> bookings = bookingService.getBookings();
        return DtoToWebMapper.toWebResponse(bookings);
    }

    @DeleteMapping(
            path = "/api/bookings/{bookingId}/delete",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> deleteBook(@PathVariable long bookingId) {
        bookingService.deleteBooking(bookingId);
        return DtoToWebMapper.toWebResponse("Delete Booking Successfully");
    }

    @PatchMapping(
            path = "/api/bookings/{bookingId}/update",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<BookingDataResponse> updateBook(@PathVariable("bookingId") Long bookingId, @RequestBody BookingUpdateStatusRequest request) {
        BookingDataResponse bookingDataResponse = bookingService.updateBooking(bookingId, request);
        return DtoToWebMapper.toWebResponse(bookingDataResponse);
    }

    @GetMapping(
            path = "/api/bookings/schedule/{id}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<ScheduleDataResponse> getScheduleByBooking(@PathVariable Long id) {
        ScheduleDataResponse schedule = bookingService.getScheduleByBooking(id);
        return DtoToWebMapper.toWebResponse(schedule);
    }
}
