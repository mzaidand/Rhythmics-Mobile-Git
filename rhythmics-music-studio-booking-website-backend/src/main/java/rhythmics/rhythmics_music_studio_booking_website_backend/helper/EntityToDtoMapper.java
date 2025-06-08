package rhythmics.rhythmics_music_studio_booking_website_backend.helper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.bookings.BookingDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.photo.PhotoDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.roomchedule.RoomScheduleDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.schedule.ScheduleDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.user.UserDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.*;

import java.util.ArrayList;
import java.util.stream.Collectors;

public class EntityToDtoMapper {

    private static final Logger log = LoggerFactory.getLogger(EntityToDtoMapper.class);

    public static UserDataResponse toUserDataResponse(User user) {
        return UserDataResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .role(user.getRole())
                .build();
    }

    public static RoomDataResponse toRoomDataResponse(Room room) {
        return RoomDataResponse.builder()
                .id(room.getId())
                .price(room.getPrice())
                .type(room.getType())
                .createdAt(room.getCreatedAt())
                .updatedAt(room.getUpdatedAt())
                .studioId(room.getStudio().getId())
                .reviews(room.getReviews() != null ? room.getReviews().stream().map(EntityToDtoMapper::toReviewDataResponse).collect(Collectors.toList()) : new ArrayList<>())
                .gallery(room.getGallery().stream().map(EntityToDtoMapper::toPhotoDataResponse).collect(Collectors.toList()))
                .roomSchedules(room.getRoomSchedules().stream().map(EntityToDtoMapper::toRoomScheduleDataResponse).collect(Collectors.toList()))
                .build();
    }

    public static RoomScheduleDataResponse toRoomScheduleDataResponse(RoomSchedule roomSchedule) {
        return RoomScheduleDataResponse.builder()
                .id(roomSchedule.getId())
                .status(roomSchedule.getStatus())
                .roomId(roomSchedule.getRoom().getId())
                .schedule(EntityToDtoMapper.toScheduleDataResponse(roomSchedule.getSchedule()))
                .build();
    }

    public static ScheduleDataResponse toScheduleDataResponse(Schedule schedule) {
        return ScheduleDataResponse.builder()
                .id(schedule.getId())
                .date(schedule.getDate())
                .timeSlot(schedule.getTimeSlot())
                .createdAt(schedule.getCreatedAt())
                .updatedAt(schedule.getUpdatedAt())
                .build();
    }

    public static ReviewDataResponse toReviewDataResponse(Review review) {
        log.info(review.getComment());
        return ReviewDataResponse.builder()
                .id(review.getId())
                .rating(review.getRating())
                .comment(review.getComment())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .roomId(review.getRoom().getId())
                .user(UserDataResponse.builder()
                        .id(review.getUser().getId())
                        .email(review.getUser().getEmail())
                        .firstName(review.getUser().getFirstName())
                        .lastName(review.getUser().getLastName())
                        .build())
                .build();
    }

    public static PhotoDataResponse toPhotoDataResponse(Photo photo) {
        return PhotoDataResponse.builder()
                .id(photo.getId())
                .photoUrl(photo.getPhotoUrl())
                .createdAt(photo.getCreatedAt())
                .updatedAt(photo.getUpdatedAt())
                .roomId(photo.getRoom().getId())
                .build();
    }

    public static StudioDataResponse toStudioDataResponse(Studio studio) {
        return StudioDataResponse.builder()
                .id(studio.getId())
                .name(studio.getName())
                .phoneNumber(studio.getPhoneNumber())
                .street(studio.getStreet())
                .district(studio.getDistrict())
                .cityOrRegency(studio.getCityOrRegency())
                .province(studio.getProvince())
                .postalCode(studio.getPostalCode())
                .latitude(studio.getLatitude())
                .longitude(studio.getLongitude())
                .rating(studio.getRating())
                .ownerId(studio.getOwner().getId())
                .rooms(studio.getRooms().stream().map(EntityToDtoMapper::toRoomDataResponse).collect(Collectors.toList()))
                .build();
    }

    public static BookingDataResponse toBookingDataResponse(Booking booking) {
        return BookingDataResponse.builder()
                .id(booking.getId())
                .customerId(booking.getCustomer().getId())
                .scheduleId(booking.getSchedule().getId())
                .status(booking.getStatus())
                .name(booking.getName())
                .price(booking.getPrice())
                .build();
    }
}
