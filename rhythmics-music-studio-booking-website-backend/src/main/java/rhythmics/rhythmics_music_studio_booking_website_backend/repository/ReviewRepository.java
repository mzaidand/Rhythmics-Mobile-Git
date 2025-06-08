package rhythmics.rhythmics_music_studio_booking_website_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Review;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findAllByRoom_Id(Integer room_id);

    List<Review> findAll();

    Optional<Review> findById(Long Id);
}
