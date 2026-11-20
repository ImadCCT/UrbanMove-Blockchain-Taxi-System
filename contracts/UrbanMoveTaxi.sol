
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


}
