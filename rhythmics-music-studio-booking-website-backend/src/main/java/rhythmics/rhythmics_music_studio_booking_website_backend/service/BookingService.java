package rhythmics.rhythmics_music_studio_booking_website_backend.service;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingUpdateStatusRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.schedule.ScheduleDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.EntityToDtoMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.*;

import java.util.List;

@Service
public class BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private RoomScheduleRepository roomScheduleRepository;

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private RoomRepository roomRepository;

    @Autowired
    private StudioRepository studioRepository;
    @Autowired
    private ValidationService validationService;

    @Transactional
    public BookingDataResponse create(User user, Long studioId, BookingAddRequest request){
        Booking booking = new Booking();
        Studio studio = studioRepository.findById(studioId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        Room room = roomRepository.findFirstByStudioAndType(studio, request.getRoomName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));

        Schedule schedule = scheduleRepository.findByDateAndTimeSlot(request.getDate(), request.getTimeSlot())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Schedule not found"));

        RoomSchedule roomSchedule = roomScheduleRepository.findByRoomAndSchedule(room, schedule)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RoomSchedule not found"));

        if (roomSchedule.getStatus().equals("not available")) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Schedule is not available");
        }

        roomSchedule.setStatus("not available");
        roomRepository.save(room);

        booking.setStatus("ongoing");
        booking.setCustomer(user);
        booking.setSchedule(schedule);
        booking.setName(studio.getName() + " - " + request.getRoomName());
        booking.setPrice(request.getPrice());
        bookingRepository.save(booking);

        return EntityToDtoMapper.toBookingDataResponse(booking);
    }

    @Transactional
    public List<BookingDataResponse> get(User user) {
        var bookings = bookingRepository.findAllByCustomer(user).stream().map(booking ->
                BookingDataResponse.builder()
                        .id(booking.getId())
                        .status(booking.getStatus())
                        .customerId(booking.getCustomer().getId())
                        .scheduleId(booking.getSchedule().getId())
                        .price(booking.getPrice())
                        .name(booking.getName())
                        .build()).toList();
        return bookings;
    }

    @Transactional
    public void delete(User user, Long bookingId) {
        var booking = bookingRepository.findByCustomerAndId(user, bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        bookingRepository.delete(booking);
    }

    @Transactional
    public BookingDataResponse updateStatus(User user, Long bookingId, BookingUpdateStatusRequest request) {
        var booking = bookingRepository.findByCustomerAndId(user, bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        booking.setStatus(request.getStatus());
        return EntityToDtoMapper.toBookingDataResponse(bookingRepository.save(booking));
    }

    @Transactional
    public List<BookingDataResponse> getBookings() {
        List<Booking> bookings = bookingRepository.findAll();
        return bookings.stream()
                .map(EntityToDtoMapper::toBookingDataResponse)
                .toList();
    }

    @Transactional
    public void deleteBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        bookingRepository.deleteById(bookingId);
    }

    @Transactional
    public BookingDataResponse updateBooking(Long bookingId, BookingUpdateStatusRequest request) {
        // Validate the request
        validationService.validate(request);

        // Retrieve the booking
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        // Retrieve the associated schedule
        Schedule schedule = booking.getSchedule();
        if (schedule == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Schedule not found for booking");
        }

        // Retrieve the RoomSchedule using the schedule
        List<RoomSchedule> roomSchedules = roomScheduleRepository.findAllBySchedule(schedule);

        if (roomSchedules.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "RoomSchedules not found for schedule");
        }

        // Update the status of all associated RoomSchedules
        for (RoomSchedule roomSchedule : roomSchedules) {
            if ("canceled".equalsIgnoreCase(request.getStatus()) || "finished".equalsIgnoreCase(request.getStatus())) {
                roomSchedule.setStatus("available");
            } else if ("ongoing".equalsIgnoreCase(request.getStatus())) {
                roomSchedule.setStatus("not available");
            }
            roomScheduleRepository.save(roomSchedule);
        }

        // Update the booking status
        booking.setStatus(request.getStatus());
        bookingRepository.save(booking);

        // Return the updated booking as DTO
        return EntityToDtoMapper.toBookingDataResponse(booking);
    }

    @Transactional
    public ScheduleDataResponse getScheduleByBooking(Long bookingId) {
        var booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        var schedule = booking.getSchedule();

        return EntityToDtoMapper.toScheduleDataResponse(schedule);
    }
}
