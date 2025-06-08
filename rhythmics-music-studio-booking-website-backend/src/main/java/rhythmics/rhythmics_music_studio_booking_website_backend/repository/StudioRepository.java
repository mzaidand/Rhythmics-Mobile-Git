package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Studio;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudioRepository extends JpaRepository<Studio, Long> {
    Optional<Studio> findFirstByOwnerAndId(User owner, Long id);
    List<Studio> findAllByOwner(User owner);

    @Query("SELECT v FROM Studio v WHERE v.rooms IS NOT EMPTY")
    List<Studio> findAllWithRooms();
}
