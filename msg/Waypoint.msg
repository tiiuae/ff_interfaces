# The GPS coordinate for the vehicle to navigate to.
# sensor_msgs/NavSatFix is the standard message for GPS data,
# containing latitude, longitude, and altitude.
sensor_msgs/NavSatFix gps_point

# The duration to wait at this waypoint after reaching it.
# A zero duration means the vehicle will immediately proceed
# to the next waypoint.
builtin_interfaces/Duration wait_time
