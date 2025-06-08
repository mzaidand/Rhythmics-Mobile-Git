package rhythmics.rhythmics_music_studio_booking_website_backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.BeanWrapperImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.studio.StudioUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.RoomSchedule;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Studio;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.EntityToDtoMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.RoomScheduleRepository;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.StudioRepository;

import java.beans.PropertyDescriptor;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudioService {

    private static final Logger log = LoggerFactory.getLogger(StudioService.class);
    @Autowired
    private StudioRepository studioRepository;

    @Autowired
    private ValidationService validationService;

    @Autowired
    private RoomScheduleRepository roomScheduleRepository;

    private void updateRoomScheduleStatus() {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now(); // Waktu sekarang

        // Cari semua RoomSchedule dengan tanggal sebelum hari ini atau tanggal hari ini dengan timeSlot yang sudah lewat
        List<RoomSchedule> pastSchedules = roomScheduleRepository.findAll().stream()
                .filter(roomSchedule -> {
                    LocalDate scheduleDate = roomSchedule.getSchedule().getDate();
                    String timeSlot = roomSchedule.getSchedule().getTimeSlot();

                    // Jika tanggal sebelum hari ini, maka langsung true
                    if (scheduleDate.isBefore(today)) {
                        return true;
                    }

                    // Jika tanggal hari ini, periksa apakah timeSlot sudah lewat
                    if (scheduleDate.isEqual(today)) {
                        return isTimeSlotPassed(timeSlot, now);
                    }

                    return false; // Selain itu, tidak perlu diperbarui
                })
                .collect(Collectors.toList());

        // Perbarui status menjadi "Not Available"
        pastSchedules.forEach(schedule -> schedule.setStatus("Not Available"));

        log.info("Updated RoomSchedules: {}", pastSchedules);

        // Simpan kembali data yang diperbarui
        roomScheduleRepository.saveAll(pastSchedules);
    }

    // Metode untuk memeriksa apakah timeSlot sudah lewat
    private boolean isTimeSlotPassed(String timeSlot, LocalDateTime now) {
        // Pecah timeSlot menjadi waktu mulai dan waktu akhir, misalnya "06:00 - 07:00"
        String[] parts = timeSlot.split(" - ");
        if (parts.length != 2) {
            log.warn("Invalid timeSlot format: {}", timeSlot);
            return false; // Abaikan jika format salah
        }

        try {
            // Parse waktu mulai
            LocalTime startTime = LocalTime.parse(parts[0].trim());

            // Gabungkan waktu mulai dengan tanggal hari ini
            LocalDateTime slotStartDateTime = LocalDateTime.of(now.toLocalDate(), startTime);

            // Periksa apakah waktu sekarang sudah melewati waktu mulai
            return now.isAfter(slotStartDateTime);
        } catch (Exception e) {
            log.error("Error parsing timeSlot: {}", timeSlot, e);
            return false; // Abaikan jika parsing gagal
        }
    }


    @Transactional
    public StudioDataResponse create(User user, StudioAddRequest request) {
        validationService.validate(request);

        Studio studio = new Studio();
        studio.setName(request.getName());
        studio.setPhoneNumber(request.getPhoneNumber());
        studio.setStreet(request.getStreet());
        studio.setDistrict(request.getDistrict());
        studio.setCityOrRegency(request.getCityOrRegency());
        studio.setProvince(request.getProvince());
        studio.setPostalCode(request.getPostalCode());
        studio.setLatitude(request.getLatitude());
        studio.setLongitude(request.getLongitude());
        studio.setOwner(user);

        studioRepository.save(studio);

        return EntityToDtoMapper.toStudioDataResponse(studio);
    }


    @Transactional(readOnly = true)
    public StudioDataResponse get(Long id) {
        updateRoomScheduleStatus();

        Studio studio = studioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        System.out.println(studio.getName());
        return EntityToDtoMapper.toStudioDataResponse(studio);
    }

    @Transactional
    public StudioDataResponse update(User user, Long id, StudioUpdateRequest request) {
        validationService.validate(request);

        Studio studio = studioRepository.findFirstByOwnerAndId(user, id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        BeanUtils.copyProperties(request, studio, getNullPropertyNames(request));

        studioRepository.save(studio);
        return EntityToDtoMapper.toStudioDataResponse(studio);
    }

    private static String[] getNullPropertyNames(Object source) {
        final BeanWrapperImpl wrapper = new BeanWrapperImpl(source);
        PropertyDescriptor[] pds = wrapper.getPropertyDescriptors();
        List<String> nullPropertyNames = new ArrayList<>();
        for (PropertyDescriptor pd : pds) {
            Object propertyValue = wrapper.getPropertyValue(pd.getName());

            if (propertyValue instanceof String && ((String) propertyValue).isEmpty()) {
                nullPropertyNames.add(pd.getName());
            }
        }
        return nullPropertyNames.toArray(new String[0]);
    }


    @Transactional
    public void delete(User user, Long id) {
        Studio studio = studioRepository.findFirstByOwnerAndId(user, id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        studioRepository.delete(studio);
    }

    @Transactional(readOnly = true)
    public List<StudioDataResponse> getAll() {
        updateRoomScheduleStatus();

        List<Studio> studios = studioRepository.findAllWithRooms();

        return studios.stream()
                .map(EntityToDtoMapper::toStudioDataResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<StudioDataResponse> getAllFromOwner(User user) {
        List<Studio> studios = studioRepository.findAllByOwner(user);

        return studios.stream()
                .map(EntityToDtoMapper::toStudioDataResponse)
                .toList();
    }

    @Transactional
    public void deleteStudioAdmin(Long id) {
        Studio studio = studioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        studioRepository.delete(studio);
    }
    @Transactional
    public void updateRating(long id , double rating) {
        Studio studio = studioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));
        studio.setRating(rating);
        studioRepository.save(studio);
    }

    @Transactional
    public StudioDataResponse updateAdmin(Long id, StudioUpdateRequest request) {
        validationService.validate(request);

        Studio studio = studioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Studio not found"));

        BeanUtils.copyProperties(request, studio, getNullPropertyNames(request));

        studioRepository.save(studio);
        return EntityToDtoMapper.toStudioDataResponse(studio);
    }
}

