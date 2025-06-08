package rhythmics.rhythmics_music_studio_booking_website_backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Review;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.Room;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.helper.EntityToDtoMapper;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.ReviewRepository;
import rhythmics.rhythmics_music_studio_booking_website_backend.repository.RoomRepository;

import java.util.List;

@Service
public class ReviewService {

    @Autowired
    private ValidationService validationService;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private RoomRepository roomRepository;


    @Transactional
    public ReviewDataResponse create(Integer roomId, User user, ReviewAddRequest request) {
        validationService.validate(request);

        Review review = new Review();
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));;
        review.setComment(request.getComment());
        review.setRoom(room);
        review.setUser(user);
        review.setRating(request.getRating());

        try {
            reviewRepository.save(review);

        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error saving review");
        }

        return EntityToDtoMapper.toReviewDataResponse(review);
    }

    @Transactional(readOnly = true)
    public List<ReviewDataResponse> getAllReviews(Integer roomId) {
        List<Review> reviews = reviewRepository.findAllByRoom_Id(roomId);

        if(reviews == null || reviews.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found");
        }

        return reviews.stream()
                .map(EntityToDtoMapper::toReviewDataResponse)
                .toList();
    }

    @Transactional
    public void delete(Long reviewId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));

        reviewRepository.delete(review);
    }

    @Transactional(readOnly = true)
    public List<ReviewDataResponse> getAlls() {
        List<Review> reviews = reviewRepository.findAll();

        return reviews.stream()
                .map(EntityToDtoMapper::toReviewDataResponse)
                .toList();
    }

    @Transactional
    public ReviewDataResponse update(long review_id, ReviewUpdateRequest request) {
        Review review = reviewRepository.findById(review_id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));

        if(request.getComment() != null) {
            review.setComment(request.getComment());
        }

        if(request.getRating() != null) {
            review.setRating(request.getRating());
        }

        reviewRepository.save(review);

        return EntityToDtoMapper.toReviewDataResponse(review);
    }

}