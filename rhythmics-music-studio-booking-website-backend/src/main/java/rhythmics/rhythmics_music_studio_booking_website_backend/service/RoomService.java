package rhythmics.rhythmics_music_studio_booking_website_backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.multipart.MultipartFile;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.room.RoomUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.EntityToDtoMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
public class RoomService {

    private static final Logger log = LoggerFactory.getLogger(RoomService.class);

    @Value("${photo.upload-dir}")
    private String uploadDir;

    @Autowired
    private RoomRepository roomRepository;

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private StudioRepository studioRepository;

    @Autowired
    private PhotoRepository photoRepository;

    @Autowired
    private ValidationService validationService;

    @Autowired
    private RoomScheduleRepository roomScheduleRepository;

    public void createScheduleIfNotExist() {
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(java.time.DayOfWeek.MONDAY);
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        List<Schedule> schedulesThisWeek = scheduleRepository.findSchedulesForWeek(startOfWeek, endOfWeek);

        if (schedulesThisWeek.isEmpty()) {
            for (int i = 0; i < 7; i++) {
                LocalDate scheduleDate = startOfWeek.plusDays(i);

                List<String> timeSlots = List.of(
                        "06:00 - 07:00", "07:00 - 08:00", "08:00 - 09:00", "09:00 - 10:00",
                        "10:00 - 11:00", "11:00 - 12:00", "12:00 - 13:00", "13:00 - 14:00",
                        "14:00 - 15:00", "15:00 - 16:00", "16:00 - 17:00", "17:00 - 18:00",
                        "18:00 - 19:00", "19:00 - 20:00", "20:00 - 21:00", "21:00 - 22:00",
                        "22:00 - 23:00", "23:00 - 00:00"
                );

                for (String timeSlot : timeSlots) {
                    Schedule newSchedule = new Schedule();
                    newSchedule.setDate(scheduleDate);
                    newSchedule.setTimeSlot(timeSlot);
                    newSchedule.setCreatedAt(LocalDateTime.now());
                    newSchedule.setUpdatedAt(LocalDateTime.now());

                    scheduleRepository.save(newSchedule);
                }
            }
        }
    }


    public RoomDataResponse add(User user, RoomAddRequest request, List<MultipartFile> files, Long studioId) {
        validationService.validate(request);

        // Validasi dan pencarian Studio
        Studio studio = studioRepository.findById(studioId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio is not found"));

        if (!Objects.equals(studio.getOwner().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not owner of this studio");
        }

        // Buat entitas Room
        Room newRoom = new Room();
        newRoom.setPrice(request.getPrice());
        newRoom.setType(request.getType());
        newRoom.setStudio(studio);

        // Simpan Room terlebih dahulu untuk mendapatkan ID
        Room finalNewRoom = roomRepository.save(newRoom);

        // Simpan daftar foto ke Gallery setelah Room memiliki ID
        List<Photo> gallery = new ArrayList<>();
        for (MultipartFile file : files) {
            String fileName = saveFileLocally(file);
            String photoUrl = "/uploads/" + fileName;

            Photo photo = new Photo();
            photo.setPhotoUrl(photoUrl);
            photo.setRoom(finalNewRoom); // Set Room yang sudah memiliki ID

            gallery.add(photo);
        }
        photoRepository.saveAll(gallery);

        List<Schedule> schedulesThisWeek = scheduleRepository.findSchedulesForWeek(
                LocalDate.now().with(java.time.DayOfWeek.MONDAY),
                LocalDate.now().with(java.time.DayOfWeek.SUNDAY)
        );
        if (schedulesThisWeek.isEmpty()) {
            createScheduleIfNotExist();
            schedulesThisWeek = scheduleRepository.findSchedulesForWeek(
                    LocalDate.now().with(java.time.DayOfWeek.MONDAY),
                    LocalDate.now().with(java.time.DayOfWeek.SUNDAY)
            );
        }

        List<RoomSchedule> roomSchedules = schedulesThisWeek.stream()
                .map(schedule -> {
                    RoomSchedule roomSchedule = new RoomSchedule();
                    roomSchedule.setRoom(finalNewRoom);
                    roomSchedule.setSchedule(schedule);
                    roomSchedule.setStatus("Available");
                    return roomSchedule;
                }).toList();

        roomScheduleRepository.saveAll(roomSchedules);

        finalNewRoom.setGallery(gallery);
        finalNewRoom.setRoomSchedules(roomSchedules);

        return EntityToDtoMapper.toRoomDataResponse(finalNewRoom);
    }


    private String saveFileLocally(MultipartFile file) {
        try {
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename().replace(" ", "_");


            File directory = new File(uploadDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            Path path = Paths.get(uploadDir, fileName);
            Files.write(path, file.getBytes());

            return fileName;
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to save file", e);
        }
    }

    public RoomDataResponse get(User user, Long studioId, Long roomId) {

        List<Schedule> schedulesThisWeek = scheduleRepository.findSchedulesForWeek(
                LocalDate.now().with(java.time.DayOfWeek.MONDAY),
                LocalDate.now().with(java.time.DayOfWeek.SUNDAY)
        );

        if (schedulesThisWeek.isEmpty()) {
            createScheduleIfNotExist();
        }

        Studio studio = studioRepository.findById(studioId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio is not found"));

        if (!Objects.equals(studio.getOwner().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not owner of this studio");
        }

        Room room = roomRepository.findFirstByIdAndStudio(roomId, studio).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room is not found"));
        return EntityToDtoMapper.toRoomDataResponse(room);
    }

    public List<RoomDataResponse> getAll(User user, Long studioId) {

        Studio studio = studioRepository.findById(studioId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio is not found"));

        if (!Objects.equals(studio.getOwner().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not owner of this studio");
        }

        List<Room> rooms = roomRepository.findAllByStudio(studio);
        return rooms.stream().map(EntityToDtoMapper::toRoomDataResponse).toList();
    }

    public RoomDataResponse update(User user, RoomUpdateRequest request, List<MultipartFile> files, Long studioId, Long roomId) {
        Studio studio = studioRepository.findById(studioId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio is not found"));

        if (!Objects.equals(studio.getOwner().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not owner of this studio");
        }

        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));

        List<RoomSchedule> existingRoomSchedules = room.getRoomSchedules();

        if (request.getRoomSchedules() != null && !request.getRoomSchedules().isEmpty()) {
            for (int i = 0; i < existingRoomSchedules.size(); i++) {
                RoomSchedule roomSchedule = existingRoomSchedules.get(i);
                String newStatus = request.getRoomSchedules().get(i).getStatus();
                if (newStatus != null) {
                    roomSchedule.setStatus(newStatus);
                }
            }
            roomScheduleRepository.saveAll(existingRoomSchedules);
        }

        if (request.getRemovedImages() != null && !request.getRemovedImages().isEmpty()) {
            List<Photo> photosToRemove = photoRepository.findAllByPhotoUrlIn(request.getRemovedImages());
            photoRepository.deleteAll(photosToRemove);

            // Hapus file dari sistem
            photosToRemove.forEach(photo -> {
                Path path = Paths.get(uploadDir, photo.getPhotoUrl().replace("/uploads/", ""));
                try {
                    Files.deleteIfExists(path);
                } catch (IOException e) {
                    log.error("Failed to delete file: " + path, e);
                }
            });
        }

        if (files != null && !files.isEmpty()) {
            List<Photo> newPhotos = files.stream().map(file -> {
                String fileName = saveFileLocally(file);
                Photo photo = new Photo();
                photo.setPhotoUrl("/uploads/" + fileName);
                photo.setRoom(room);
                return photo;
            }).toList();
            photoRepository.saveAll(newPhotos);
            room.getGallery().addAll(newPhotos);
        }

        if (request.getPrice() != null) {
            room.setPrice(request.getPrice());
        }

        if (request.getType() != null) {
            room.setType(request.getType());
        }


        roomRepository.save(room);

        return EntityToDtoMapper.toRoomDataResponse(room);
    }

    public void delete(User user, Long studioId, Long roomId) {
        Studio studio = studioRepository.findById(studioId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio is not found"));

        if (!Objects.equals(studio.getOwner().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not owner of this studio");
        }

        Room room = roomRepository.findFirstByIdAndStudio(roomId, studio).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room is not found"));

        roomRepository.delete(room);
    }

    public List<RoomDataResponse> getAllRoom() {
        List<Room> rooms = roomRepository.findAll();
        return rooms.stream().map(EntityToDtoMapper::toRoomDataResponse).toList();
    }

}
