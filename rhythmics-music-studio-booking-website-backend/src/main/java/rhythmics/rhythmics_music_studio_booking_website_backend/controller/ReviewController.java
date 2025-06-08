package rhythmics.rhythmics_music_studio_booking_website_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.WebResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewAddRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewDataResponse;
import rhythmics.rhythmics_music_studio_booking_website_backend.dto.review.ReviewUpdateRequest;
import rhythmics.rhythmics_music_studio_booking_website_backend.entity.User;
import rhythmics.rhythmics_music_studio_booking_website_backend.service.ReviewService;

import java.util.List;

@RestController
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @PostMapping(
            path = "/api/rooms/{roomId}/reviews",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<ReviewDataResponse> create(@PathVariable("roomId") Integer roomId , User user, @RequestBody ReviewAddRequest request){
        ReviewDataResponse reviewDataResponse = reviewService.create(roomId,user,request);

        return WebResponse.<ReviewDataResponse>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data(reviewDataResponse)
                .build();
    }

    @DeleteMapping(
            path = "/api/reviews/{reviewId}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<String> delete(@PathVariable("reviewId") Long reviewId){
        reviewService.delete(reviewId);
        return WebResponse.<String>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data("Review Deleted Successfully")
                .build();
    }

    @GetMapping(
            path = "/api/{roomId}/reviews",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<ReviewDataResponse>> getAllReviews(@PathVariable("roomId") Integer roomId){
        List<ReviewDataResponse> reviewDataResponses = reviewService.getAllReviews(roomId);
        return WebResponse.<List<ReviewDataResponse>>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data(reviewDataResponses)
                .build();
    }

    @GetMapping(
            path = "/api/reviews",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<List<ReviewDataResponse>> getAlls(){
        List<ReviewDataResponse> reviewDataResponses = reviewService.getAlls();
        return WebResponse.<List<ReviewDataResponse>>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data(reviewDataResponses)
                .build();
    }

    @PatchMapping(
            path = "/api/reviews/{reviewId}",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public WebResponse<ReviewDataResponse> update(@PathVariable("reviewId") Long reviewId, @RequestBody ReviewUpdateRequest request){
        ReviewDataResponse review = reviewService.update(reviewId,request);
        return WebResponse.<ReviewDataResponse>builder()
                .code(HttpStatus.OK.value())
                .status(HttpStatus.OK.getReasonPhrase())
                .data(review)
                .build();
    }


}
