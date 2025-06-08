package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Room;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.RoomSchedule;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Schedule;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface RoomScheduleRepository extends JpaRepository<RoomSchedule, Long> {

    List<RoomSchedule> findBySchedule(Schedule schedule);
    List<RoomSchedule> findAllByRoom(Room room);
    RoomSchedule findFirstByRoom(Room room);
    List<RoomSchedule> findAllBySchedule_DateBeforeAndStatus(LocalDate date, String status);

    Optional<RoomSchedule> findByRoomAndSchedule(Room room, Schedule schedule);
    List<RoomSchedule> findAllBySchedule(Schedule schedule);
}
