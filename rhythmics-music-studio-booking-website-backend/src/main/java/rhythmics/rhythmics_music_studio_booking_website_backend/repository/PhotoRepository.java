package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Photo;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Room;

import java.util.List;
import java.util.Set;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {

    Photo findByPhotoUrl(String photoUrl);
    List<Photo> findByPhotoUrlIn(Set<String> photoUrls);
    List<Photo> findAllByPhotoUrlIn(List<String> photoUrls);

    void deleteAllByRoom(Room room);
}
