
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract UrbanMoveTaxi {

    // Booking statuses
    enum BookingStatus {
        Requested,
        Accepted,
        Completed,
        Cancelled
    }

    // Booking information
    struct Booking {
        uint256 bookingId;
        address passenger;
        address driver;
        uint256 fare;
        BookingStatus status;
    }

    // Store all taxi bookings
    mapping(uint256 => Booking) public bookings;

    // Generate unique booking IDs
    uint256 public nextBookingId = 1;

    bool private locked;

modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}


    // Events
    event BookingCreated(
        uint256 bookingId,
        address passenger,
        uint256 fare
    );

    event BookingAccepted(
        uint256 bookingId,
        address driver
    );

    event JourneyCompleted(
        uint256 bookingId,
        address driver,
        uint256 fare
    );

    event BookingCancelled(
        uint256 bookingId,
        address passenger,
        uint256 refund
    );


function createBooking() public payable {
    require(msg.value > 0, "Fare must be greater than zero");

    uint256 bookingId = nextBookingId;

    bookings[bookingId] = Booking({
        bookingId: bookingId,
        passenger: msg.sender,
        driver: address(0),
        fare: msg.value,
        status: BookingStatus.Requested
    });

    nextBookingId++;

    emit BookingCreated(
        bookingId,
        msg.sender,
        msg.value
    );
}

// Accept an existing taxi booking
function acceptBooking(uint256 _bookingId) public {

    require(
        _bookingId > 0 && _bookingId < nextBookingId,
        "Booking does not exist"
    );

    Booking storage booking = bookings[_bookingId];

    require(
        booking.status == BookingStatus.Requested,
        "Booking is not available"
    );

    require(
    msg.sender != booking.passenger,
    "Passenger cannot accept their own booking"
);

    booking.driver = msg.sender;
    booking.status = BookingStatus.Accepted;

    emit BookingAccepted(_bookingId, msg.sender);
}

// Complete a taxi journey and release the fare payment
function completeJourney(uint256 _bookingId) public nonReentrant {
    require(
        _bookingId > 0 && _bookingId < nextBookingId,
        "Booking does not exist"
    );

    Booking storage booking = bookings[_bookingId];

    require(
        booking.status == BookingStatus.Accepted,
        "Booking is not active"
    );

    require(
        msg.sender == booking.driver,
        "Only the assigned driver can complete the journey"
    );

    booking.status = BookingStatus.Completed;

    (bool success, ) = payable(booking.driver).call{value: booking.fare}("");
    require(success, "Payment transfer failed");

    emit JourneyCompleted(
        _bookingId,
        booking.driver,
        booking.fare
    );
}

// Cancel an existing taxi booking
function cancelBooking(uint256 _bookingId) public nonReentrant {
    require(
        _bookingId > 0 && _bookingId < nextBookingId,
        "Booking does not exist"
    );

    Booking storage booking = bookings[_bookingId];

    require(
        msg.sender == booking.passenger,
        "Only the passenger can cancel"
    );

    require(
        booking.status == BookingStatus.Requested ||
        booking.status == BookingStatus.Accepted,
        "Booking cannot be cancelled"
    );

    booking.status = BookingStatus.Cancelled;
    (bool success, ) = payable(booking.passenger).call{value: booking.fare}("");
require(success, "Refund transfer failed");

    emit BookingCancelled(
        _bookingId,
        booking.passenger,
        booking.fare
    );
}


}
