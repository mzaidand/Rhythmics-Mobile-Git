package rhythmics.rhythmics_music_studio_booking_website_backend.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Booking;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;

import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findAllByCustomer(User customer);

    Optional<Booking> findByCustomerAndId(User customer,Long id);
}
