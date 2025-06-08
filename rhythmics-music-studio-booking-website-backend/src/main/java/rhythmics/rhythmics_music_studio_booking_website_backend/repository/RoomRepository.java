package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Room;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Studio;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {
    Optional<Room> findFirstByIdAndStudio(Long id, Studio studio);
    List<Room> findAllByStudio(Studio studio);
    Optional<Room> findById(Integer id);

    List<Room> findAll();

    Optional<Room> findFirstByStudioAndType(Studio studio, String type);
}
